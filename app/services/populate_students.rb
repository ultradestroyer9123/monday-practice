class PopulateStudents
  
  def self.process
    obj = new
    obj.run
  end

  def initialize
    @board_id = 18371055063
    @column_map = MondayBoardColumnMap.new(@board_id)
    @client = Monday::Client.new(
      token: ENV['MONDAY_DEV_KEY'],
      version: '2024-10'
    )
  end

  def run
    student_map = populate_items
    student_map
  end

  private

  def populate_items
    pulse_id_database_id_map = {}

    Student.all.each do |student|
      args = {
        board_id: @board_id,
        item_name: student.name,
        column_values: column_values(student)
      }
      response = @client.item.create(args: args, select: ['id'])
      pulse_id_database_id_map[student.id] = response.body['data']['create_item']['id']
    end

    pulse_id_database_id_map
  end

  def column_values(student)
    grade_map = {9 => "9th", 10 => "10th", 11 => "11th", 12 => "12th"}
    
    mapped_values = {}
    mapped_values[@column_map.convert_name("Email")] = student.email
    mapped_values[@column_map.convert_name("Phone")] = student.phone || "N/A"
    mapped_values[@column_map.convert_name("Grade")] = grade_map[student.grade] || "N/A"
    mapped_values[@column_map.convert_name("Database ID")] = student.id.to_s
    mapped_values
  end
end