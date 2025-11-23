class DuplicateWorkspace
  
  def self.process(workspace_id:, new_name:)
    obj = new(workspace_id: workspace_id, new_name: new_name)
    obj.run
  end

  def initialize(workspace_id:, new_name:)
    @workspace_id = workspace_id
    @new_name = new_name
    @client = Monday::Client.new(
      token: ENV['MONDAY_DEV_KEY'],
      version: '2025-10'
    )
  end

  def run
    create_workspace_structure
    # create_new_workspace
  end

  private

  def create_workspace_structure
    raw_items = fetch_workspace_items
    @workspace_structure = {
      workspace: {
        name: @new_name,
        id: @workspace_id,
        contents: raw_items.map do |item|
          {
            kind: item["type"], # board, document, custom_object, etc
            id: item["id"],
            name: item["name"],
            description: item["description"],
            folder_id: item["board_folder_id"],

            columns: (item["columns"] || []).map do |col|
              {
                id: col["id"],
                title: col["title"],
                column_type: col["type"],
                settings: col["settings_str"] || col["settings"] || {}
              }
            end,

            groups: (item["groups"] || []).map do |group|
              {
                id: group["id"],
                title: group["title"],
                color: group["color"]
              }
            end
          }
        end
      }
    }

    puts @workspace_structure
  end

  def fetch_workspace_items
    response = @client.board.query(
      args: { workspace_ids: [@workspace_id] },
      select: ["id", "name", "type", "description", "board_folder_id", "columns { id title type settings_str }", "groups { id title color }"]
    )

    boards = response.body.dig("data", "boards")
  end
end


# Hash structure
# {workspace_name: "Clone - name", items: [{name: "name", type: "board", content: {}}]}