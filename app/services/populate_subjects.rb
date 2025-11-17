class PopulateSubjects
  
  def self.process
    obj = new
    obj.run
  end

  def initialize
    @board_id = 18371055181
    @column_map = MondayBoardColumnMap.new(@board_id)
    @client = Monday::Client.new(
      token: ENV['MONDAY_DEV_KEY'],
      version: '2024-10'
    )
  end

  def run
    subject_map = populate_items
    subject_map
  end

  private

  def populate_items
    pulse_id_database_id_map = {}

    Subject.all.each do |subject|
      args = {
        board_id: @board_id,
        item_name: subject.name,
        column_values: column_values(subject)
      }

      response = @client.item.create(args: args, select: ['id'])
      pulse_id_database_id_map[subject.id] = response.body['data']['create_item']['id']
    end

    pulse_id_database_id_map
  end

  def column_values(subject)
    mapped_values = {}
    mapped_values[@column_map.convert_name("Core")] = subject.core ? "Yes" : "No"
    mapped_values[@column_map.convert_name("Database ID")] = subject.id.to_s
    mapped_values
  end
end
