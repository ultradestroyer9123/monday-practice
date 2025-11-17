class FetchItemsFromBoard

  def initialize
    @client = Monday::Client.new(
      token: ENV['MONDAY_DEV_KEY'],
      version: '2024-10'
    )
  end

  def fetch(board_id)
    @board_id = board_id
    fetch_items
  end

  private

  def fetch_items
    request_query = <<-GRAPHQL
      items_page (limit: 500) {
        items {
          id
          name
          column_values {
            id
            text
            value
            column { title }
          }
        }
      }
    GRAPHQL
    
    response = @client.board.query(args: {ids: @board_id}, select: ['id', 'name', request_query])

    response.body['data']['boards'].first['items_page']['items']
  end
end