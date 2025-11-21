class MondayApiClient
  API_URL = 'https://api.monday.com/v2'
  
  def initialize(token: ENV['MONDAY_DEV_KEY'], api_version: '2024-10')
    @token = token
    @api_version = api_version
  end
  
  def execute(query)
    uri = URI(API_URL)
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Authorization'] = @token
    request['API-Version'] = @api_version
    request.body = { query: query }.to_json
    
    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
    
    result = JSON.parse(response.body)
    
    if result['errors']
      raise "Monday.com API Error: #{result['errors'].map { |e| e['message'] }.join(', ')}"
    end
    
    result['data']
  end
  
  def query(graphql_query)
    execute("query { #{graphql_query} }")
  end
  
  def mutation(graphql_mutation)
    execute("mutation { #{graphql_mutation} }")
  end
end
