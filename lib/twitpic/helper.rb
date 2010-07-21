module Twitpic
  module Helper
    # TODO better solution...
    def detect_image_type(path_to_image)
      image_file_name = File.basename(path_to_image)
      case image_file_name
      when /\.jpe?g$/i
        mime_type = "image/jpeg"
      when /\.gif$/i
        mime_type = "image/gif"
      when /\.png$/i
        mime_type = "image/png"
      else
        mime_type = "image/jpeg"
      end
    end
    
    
    def create_http_request_body(path_to_image, message, api_key, boundary)
      mime_type = detect_image_type(path_to_image)
      image_file_name = File.basename(path_to_image)
      
      body_part = []
      body_part << "--#{boundary}"
      body_part << "Content-Disposition: form-data; name=\"key\""
      body_part << ""
      body_part << api_key

      unless message == ""
        body_part << "--#{boundary}" 
        body_part << "Content-Disposition: form-data; name=\"message\""
        body_part << ""
        message.split(/\n/).each{|line|
          body_part << "#{line}"
        }
      end
      body_part << "--#{boundary}"
      body_part << "Content-Disposition: form-data; name=\"media\"; filename=\"#{image_file_name}\""
      body_part << "Content-Type: #{mime_type}"
      body_part << ""
      open(path_to_image, "rb"){|io|
        body_part << io.read
      }
      body_part << "--#{boundary}--"
      body_part << ""
      return body_part.join("\r\n")
    end
  end
end