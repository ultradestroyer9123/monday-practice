class GenerateStudentPandadoc
  PANDADOC_API_KEY = ENV['PANDADOC_API_KEY']
  TEMPLATE_UUID = ENV['PANDADOC_TEMPLATE_UUID']
  MONDAY_DEV_KEY = ENV['MONDAY_DEV_KEY']

  def self.process(pulse_id = nil)
    obj = new(pulse_id)
    obj.run
  end

  def initialize(pulse_id = nil)
    @pulse_id = pulse_id
    @student_board_id = 18380266024  # Updated to match webhook board
    @client = Monday::Client.new(
      token: MONDAY_DEV_KEY,
      version: '2024-10'
    )
    @board_fetcher = FetchItemsFromBoard.new
    configure_pandadoc
  end

  def run
    @student = fetch_student_data
    document = create_document
    filename = download_document(document.uuid)
    upload_file_to_monday(filename)
  end

  private

  def fetch_student_data
    return default_student unless @pulse_id
    
    student_item = fetch_single_item(@pulse_id)
    return default_student unless student_item
    
    {
      email: get_column_value(student_item, 'Email'),
      first_name: extract_first_name(student_item['name']),
      last_name: extract_last_name(student_item['name']),
      address: get_column_value(student_item, 'Address') || "Address not available"
    }
  end

  def fetch_single_item(item_id)
    # Handle both string and integer pulse_ids
    pulse_id = item_id.is_a?(Hash) ? item_id[:pulseId] || item_id["pulseId"] : item_id
    
    response = @client.item.query(
      args: { ids: [pulse_id.to_i] },
      select: ["id", "name", { column_values: ["id", "text", { column: ["title"] }] }]
    )
    response.body.dig("data", "items")&.first
  end

  def get_column_value(item, column_title)
    column = item['column_values'].find { |col| col['column']['title'] == column_title }
    column&.dig('text')
  end

  def extract_first_name(full_name)
    full_name.split(' ').first
  end

  def extract_last_name(full_name)
    parts = full_name.split(' ')
    parts.size > 1 ? parts.last : ''
  end

  def configure_pandadoc
    require 'panda_doc'
    PandaDoc.configure do |config|
      config.api_key = PANDADOC_API_KEY
    end
  end

  def create_document
    PandaDoc::Document.create(
      name: "#{@student[:first_name]} #{@student[:last_name]} Contract",
      template_uuid: TEMPLATE_UUID,
      recipients: [recipient_data],
      tokens: token_data,
      fields: {}
    )
  end

  def recipient_data
    {
      email: @student[:email],
      first_name: @student[:first_name],
      last_name: @student[:last_name],
      role: "Tenant",
      default: true
    }
  end

  def token_data
    [
      { name: "FirstName", value: "#{@student[:first_name]}" },
      { name: "LastName", value: "#{@student[:last_name]}" },
      { name: "Email", value: @student[:email] },
      { name: "Address", value: @student[:address] },
    ]
  end

  def download_document(document_uuid)
    sleep 10 # Wait for document generation
    
    response = PandaDoc::Document.download(document_uuid)
    filename = "#{@student[:first_name]}_#{@student[:last_name]}_contract.pdf"
    
    File.open(filename, "wb") do |f|
      f.write(response.body)
    end
    
    puts "PDF downloaded successfully: #{filename}"
    filename
  end

  def upload_file_to_monday(filename)
    return unless @pulse_id && File.exist?(filename)
    
    file_path = File.expand_path(filename)
    puts "Attempting to upload file for pulse_id: #{@pulse_id}"
    
    begin
      # Get the column ID for "Files" column using the correct token
      files_column_id = "files"  # Common Monday.com files column ID
      
      puts "Using Files column ID: #{files_column_id}"
      args = {
          board_id: @student_board_id,
          item_id: @pulse_id.to_i,
          column_id: files_column_id,
          file: file_path
        }
      binding.pry
      # Upload file to the Files column
      file_response = @client.column.change_value(
        args: args
      )
      
      puts "File upload response: #{file_response.body.inspect}"
      
      if file_response.body.dig("data", "change_column_value")
        puts "File uploaded successfully to Files column for student #{@pulse_id}"
        File.delete(filename)  # Clean up local file
        puts "Local file #{filename} deleted"
      else
        puts "Failed to upload file to Files column"
        puts file_response.body.inspect
      end
    rescue => e
      puts "Error uploading file to Monday.com: #{e.message}"
      puts e.backtrace
    end
  end

  def default_student
    {
      email: "benjaminphays@gmail.com",
      first_name: "Benjamin",
      last_name: "Hays",
      address: "5535 Carmen St, San Diego, CA 92105",
    }
  end
end
