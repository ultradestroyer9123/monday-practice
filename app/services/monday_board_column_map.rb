class MondayBoardColumnMap

  def initialize(board_id)
    @board_id = board_id
  end

  def convert_name(column_name)
    @column_mapping ||= fetch_column_mapping
    @column_mapping[column_name]
  end

  private

  def fetch_column_mapping
    client = Monday::Client.new(
      token: ENV['MONDAY_DEV_KEY'],
      version: '2024-10'
    )
    args = { ids: @board_id }
    response = client.board.query(args: args, select: ['id', 'name', 'columns { id title type }'])
    columns = response.body['data']['boards'].first['columns']

    mapping = {}
    columns.each do |column|
      mapping[column['title']] = column['id']
    end
    
    mapping
  end
end