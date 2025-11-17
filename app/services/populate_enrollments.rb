class PopulateEnrollments
  
  def self.process(students_map, teachers_map)
    obj = new(students_map, teachers_map)
    obj.run
  end

  def initialize(students_map, teachers_map)
    @board_id = 18371055110
    @column_map = MondayBoardColumnMap.new(@board_id)
    @students_map = students_map
    @teachers_map = teachers_map
    @client = Monday::Client.new(
      token: ENV['MONDAY_DEV_KEY'],
      version: '2024-10'
    )
  end

  def run
    enrollment_map = populate_items
    enrollment_map
  end

  private

  def populate_items
    pulse_id_database_id_map = {}

    Enrollment.all.each do |enrollment|
      args = {
        board_id: @board_id,
        item_name: enrollment.student.name,
        column_values: column_values(enrollment)
      }
      response = @client.item.create(args: args, select: ['id'])
      pulse_id_database_id_map[enrollment.id] = response.body['data']['create_item']['id']
    end

    pulse_id_database_id_map
  end

  def column_values(enrollment)
    period_map = {1 => "1st", 2 => "2nd", 3 => "3rd", 4 => "4th", 5 => "5th", 6 => "6th", 7 => "7th"}
    
    mapped_values = {}
    mapped_values[@column_map.convert_name("Subject")] = enrollment.subject
    mapped_values[@column_map.convert_name("Core")] = enrollment.core ? 'Yes' : 'No'
    mapped_values[@column_map.convert_name("Period")] = period_map[enrollment.period] || "N/A"
    mapped_values[@column_map.convert_name("Student ID")] = enrollment.student.id.to_s
    mapped_values[@column_map.convert_name("Teacher ID")] = enrollment.teacher.id.to_s
    mapped_values[@column_map.convert_name("Database ID")] = enrollment.id.to_s
    mapped_values[@column_map.convert_name("Teachers")] = { item_ids: [@teachers_map[enrollment.teacher.id]]}
    mapped_values[@column_map.convert_name("Students")] = { item_ids: [@students_map[enrollment.student.id]]}
    mapped_values
  end
end
