class CreateMondayBoard
  
  def self.process(board_name:, workspace_id: 13301830, folder_id: nil, columns: {})
    obj = new(board_name: board_name, workspace_id: workspace_id, folder_id: folder_id, columns: columns)
    obj.run
  end

  def initialize(board_name:, workspace_id: nil, folder_id: nil, columns: {})
    @board_name = board_name
    @workspace_id = workspace_id
    @folder_id = folder_id
    @columns = columns
    @api_client = MondayApiClient.new
  end

  def run
    board = create_board
    create_columns(board['id']) if @columns.any?
    puts "Board created successfully: ID #{board['id']}, Name: #{board['name']}"
    board
  end

  private

  def create_board
    # Build the mutation arguments
    args = []
    args << "board_name: \"#{@board_name}\""
    args << "board_kind: public"
    args << "empty: true" 
    args << "workspace_id: #{@workspace_id}" if @workspace_id && !@folder_id
    args << "folder_id: #{@folder_id}" if @folder_id
    
    mutation = <<-GRAPHQL
      create_board(#{args.join(', ')}) {
        id
        name
        description
      }
    GRAPHQL
    
    @api_client.mutation(mutation.strip)['create_board']
  end

  def create_columns(board_id)
    @columns.each do |column_name, column_type|
      mutation = <<-GRAPHQL
        create_column(board_id: #{board_id}, title: "#{column_name}", column_type: #{column_type}) {
          id
          title
          type
        }
      GRAPHQL
      
      result = @api_client.mutation(mutation.strip)
      puts "Created column: #{column_name} (#{column_type})"
    end
  end
end
