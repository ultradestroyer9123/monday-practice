class CreateMondayColumns
  
  def self.process(board_id:, columns: {})
    obj = new(board_id: board_id, columns: columns)
    obj.run
  end

  def initialize(board_id:, columns: {})
    @board_id = board_id
    @columns = columns
    @client = Monday::Client.new(
      token: ENV['MONDAY_DEV_KEY'],
      version: '2025-10'
    )
    @api_client = MondayApiClient.new
  end

  def run
    create_columns
    puts "Columns created successfully for board ID #{@board_id}"
  end

  def create_connect_board(connected_board_id, column_title: "Connected Board")
    # Use MondayApiClient because the gem has issues with JSON in defaults
    mutation = <<-GRAPHQL
      create_column(
        board_id: #{@board_id},
        title: "#{column_title}",
        column_type: board_relation,
        defaults: "{\\\"boardIds\\\":[#{connected_board_id.to_i}]}"
      ) {
        id
        title
        type
      }
    GRAPHQL
    
    result = @api_client.mutation(mutation.strip)
    
    if result['create_column']
      column = result['create_column']
      puts "Created connect board column: #{column_title} linked to board #{connected_board_id}"
      column['id']
    else
      puts "Failed to create connect board column"
      nil
    end
  end

  private

  def create_columns
    @columns.each do |column_name, column_type|
      response = @client.column.create(
        args: {
          board_id: @board_id,
          title: column_name.to_s,
          column_type: column_type
        },
        select: ['id', 'title', 'type']
      )
      
      if response.body.dig('data', 'create_column')
        puts "Created column: #{column_name} (#{column_type})"
      else
        puts "Failed to create column: #{column_name}"
      end
    end
  end
end
