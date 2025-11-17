class PopulateTeachers
  
  def self.process(subjects_map)
    obj = new(subjects_map)
    obj.run
  end

  def initialize(subjects_map)
    @board_id = 18371055160
    @column_map = MondayBoardColumnMap.new(@board_id)
    @subjects_map = subjects_map
    @client = Monday::Client.new(
      token: ENV['MONDAY_DEV_KEY'],
      version: '2024-10'
    )
  end

  def run
    teacher_map = populate_items
    teacher_map
  end

  private

  def populate_items
    pulse_id_database_id_map = {}

    Teacher.all.each do |teacher|
      args = {
        board_id: @board_id,
        item_name: teacher.name,
        column_values: column_values(teacher)
      }
      response = @client.item.create(args: args, select: ['id'])
      pulse_id_database_id_map[teacher.id] = response.body['data']['create_item']['id']
    end

    pulse_id_database_id_map
  end

  def column_values(teacher)
    mapped_values = {}
    mapped_values[@column_map.convert_name("Email")] = teacher.email
    mapped_values[@column_map.convert_name("Phone")] = teacher.phone || 'N/A'
    mapped_values[@column_map.convert_name("Subjects")] = { item_ids: [@subjects_map[teacher.subject_id]]}
    mapped_values[@column_map.convert_name("Database ID")] = teacher.id.to_s
    mapped_values
  end
end