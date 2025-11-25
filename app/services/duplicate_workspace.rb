class DuplicateWorkspace
  
  def self.process(original_workspace_id:, new_workspace_id: nil, new_name: nil)
    obj = new(original_workspace_id: original_workspace_id, new_workspace_id: new_workspace_id, new_name: new_name)
    obj.run
  end

  def initialize(original_workspace_id:, new_workspace_id: nil, new_name: nil)
    @original_workspace_id = original_workspace_id
    @workspace_structure = nil
    @new_workspace_id = new_workspace_id
    @new_name = new_name

    @folder_map = {}
    @board_map = {}

    @client = Monday::Client.new(
      token: ENV['MONDAY_DEV_KEY'],
      version: '2025-10'
    )
    @api_client = MondayApiClient.new
  end

  def run
    fetch_workspace_items
    create_workspace if @new_workspace_id.nil?
    create_new_workspace_or_paste_into_workspace_in_monday
  end

  private

  def fetch_workspace_items
    # Fetch all boards in the workspace with full details
    board_response = @client.board.query(
      args: { workspace_ids: [@original_workspace_id] },
      select: [
        "id", 
        "name", 
        "type",
        "description", 
        "board_folder_id", 
        "columns { id title type settings_str }", 
        "groups { id title color }"
      ]
    )
    
    boards = board_response.body.dig("data", "boards")
    
    # Fetch all folders in the workspace
    folder_response = @client.folder.query(args: { workspace_ids: [@original_workspace_id] })
    folders = folder_response.body.dig("data", "folders")
    
    @workspace_structure = {
      boards: boards,
      folders: folders
    }
  end

  def create_new_workspace_or_paste_into_workspace_in_monday
    create_folders
    create_boards
    create_groups
    create_columns
  end

  def create_workspace
    response = @client.workspace.create(args: { name: @new_name, kind: :open })
    @new_workspace_id = response.body.dig('data', 'create_workspace', 'id')
  end

  def create_folders
    folders = @workspace_structure[:folders]
    return if folders.nil? || folders.empty?

    mutations = folders.map.with_index do |folder, idx|
      <<~GRAPHQL
        folder#{idx}: create_folder(
          name: "#{folder['name'].gsub('"', '\\"')}"
          workspace_id: #{@new_workspace_id}
        ) {
          id
        }
      GRAPHQL
    end

    result = @api_client.mutation(mutations.join("\n"))
    
    folders.each_with_index do |folder, idx|
      @folder_map[folder['id']] = result["folder#{idx}"]['id']
    end
  end

  def create_boards
    boards = @workspace_structure[:boards]
    boards_to_create = boards.reject { |b| b['type'] == 'custom_object' || b['type'] == 'document' || b['type'] == 'sub_items_board' }
    
    mutations = boards_to_create.map.with_index do |board, idx|
      folder_id = board['board_folder_id'] ? @folder_map[board['board_folder_id']] : nil
      description = board['description'] ? "description: \"#{board['description'].gsub('"', '\\"')}\"" : ""
      folder_param = folder_id ? "folder_id: #{folder_id}" : "workspace_id: #{@new_workspace_id}"
      
      <<~GRAPHQL
        board#{idx}: create_board(
          board_name: "#{board['name'].gsub('"', '\\"')}"
          board_kind: public
          empty: true
          #{folder_param}
          #{description}
        ) {
          id
        }
      GRAPHQL
    end

    result = @api_client.mutation(mutations.join("\n"))
    
    boards_to_create.each_with_index do |board, idx|
      @board_map[board['id']] = result["board#{idx}"]['id']
    end
  end

  def create_groups
    boards = @workspace_structure[:boards]
    all_mutations = []
    mutation_index = 0

    boards.each do |board|
      next unless @board_map[board['id']]
      groups = board['groups']
      next if groups.nil? || groups.size <= 1

      groups[1..-1].each do |group|
        all_mutations << <<~GRAPHQL
          group#{mutation_index}: create_group(
            board_id: #{@board_map[board['id']]}
            group_name: "#{group['title'].gsub('"', '\\"')}"
          ) {
            id
          }
        GRAPHQL
        mutation_index += 1
      end
    end

    @api_client.mutation(all_mutations.join("\n")) if all_mutations.any?
  end

  def create_columns
    boards = @workspace_structure[:boards]
    all_mutations = []
    mutation_index = 0

    boards.each do |board|
      next unless @board_map[board['id']]
      columns = board['columns']
      next if columns.nil?

      non_relation_columns = columns.reject { |c| c['id'] == 'name' || c['type'] == 'board_relation' || c['type'] == 'subtasks' }
      
      non_relation_columns.each do |column|
        settings = column['settings_str']
        defaults_param = settings.empty? || settings == "{}" ? "" : "defaults: #{settings.inspect}"
        
        all_mutations << <<~GRAPHQL
          col#{mutation_index}: create_column(
            board_id: #{@board_map[board['id']]}
            title: "#{column['title'].gsub('"', '\\"')}"
            column_type: #{column['type']}
            #{defaults_param}
          ) {
            id
          }
        GRAPHQL
        mutation_index += 1
      end
    end

    if all_mutations.any?
      puts "DEBUG: Column mutations:"
      puts all_mutations.join("\n")
      @api_client.mutation(all_mutations.join("\n"))
    end
    
    create_relation_columns
  end

  def create_relation_columns
    boards = @workspace_structure[:boards]
    all_mutations = []
    mutation_index = 0

    boards.each do |board|
      next unless @board_map[board['id']]
      columns = board['columns']
      next if columns.nil?

      relation_columns = columns.select { |c| c['type'] == 'board_relation' }
      
      relation_columns.each do |column|
        settings = JSON.parse(column['settings_str']) rescue {}
        
        # Map old board IDs to new board IDs
        if settings['boardIds'] && settings['boardIds'].any?
          new_board_ids = settings['boardIds'].map { |id| @board_map[id.to_s] }.compact
          
          # Skip if no valid board IDs after mapping
          next if new_board_ids.empty?
          
          # Build the defaults object with mapped board IDs
          board_ids_str = new_board_ids.join(', ')
          
          all_mutations << <<~GRAPHQL
            rel#{mutation_index}: create_column(
              board_id: #{@board_map[board['id']]}
              title: "#{column['title'].gsub('"', '\\"')}"
              column_type: board_relation
              defaults: {
                boardIds: [#{board_ids_str}]
                allowMultipleItems: true
                allowCreateReflectionColumn: true
              }
            ) {
              id
            }
          GRAPHQL
          mutation_index += 1
        end
      end
    end

    if all_mutations.any?
      puts "Creating board_relation columns..."
      @api_client.mutation(all_mutations.join("\n"))
    end
  end
end


# Hash structure
# {workspace_name: "Clone - name", items: [{name: "name", type: "board", content: {}}]}