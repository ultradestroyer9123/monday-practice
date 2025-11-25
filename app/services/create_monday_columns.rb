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

  def create_connect_board(connected_board_id:, column_title: "Connected Board")
    # Step 1: Create the board_relation column with empty settings
    create_mutation = <<-GRAPHQL
      create_column(
        board_id: #{@board_id},
        title: "#{column_title}",
        column_type: board_relation,
        defaults: "{\\"settings\\":{}}"
      ) {
        id
        title
        type
      }
    GRAPHQL
    
    puts "DEBUG: Creating board_relation column with mutation:"
    puts create_mutation
    
    result = @api_client.mutation(create_mutation.strip)
    
    puts "DEBUG: Create result: #{result.inspect}"
    
    if result['create_column']
      column = result['create_column']
      column_id = column['id']
      puts "Created board_relation column: #{column_title}"
      
      # Step 2: Update the column with the connected board ID
      update_mutation = <<-GRAPHQL
        change_column_value(
          board_id: #{@board_id},
          item_id: #{@board_id},
          column_id: "#{column_id}",
          value: "{\\"settings\\":{\\"boardIds\\":[#{connected_board_id.to_i}]}}"
        ) {
          id
        }
      GRAPHQL
      
      puts "DEBUG: Updating column with mutation:"
      puts update_mutation
      
      puts "Linking board #{connected_board_id} to column #{column_title}"
      update_result = @api_client.mutation(update_mutation.strip)
      
      puts "DEBUG: Update result: #{update_result.inspect}"
      
      column_id
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
