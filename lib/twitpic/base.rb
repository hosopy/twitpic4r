module Twitpic
  class Base
    include Twitpic::Helper
    
    attr_reader :client
    
    def initialize(api_key, client)
      @api_key = api_key
      @client = client
    end
    
    def upload(path_to_image, message)
      # HTTP request body and headers
      boundary = Time.now.strftime("%Y%m%d_%H%M%S_#{$$}")
      body = create_http_request_body(path_to_image, message, @api_key, boundary)
      headers = {}
      headers['Content-Type'] = "multipart/form-data; boundary=#{boundary}"
      headers['Content-Length'] = body.size

      # perform request
      client.post(UPLOAD_URL, body, headers)
    end
  end
end