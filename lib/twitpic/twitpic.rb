module Twitpic
  SITE_URL = 'http://twitpic.com/'
  API_URL = 'http://api.twitpic.com/2/'
  UPLOAD_URL = "#{API_URL}upload.json"
  
  class TwitpicError < StandardError
    attr_reader :data
    
    def initialize(data)
      @data = data
      super
    end
  end
  
  class NotImplemented < TwitpicError; end
  class HttpError < TwitpicError; end
  class Unauthorized < TwitpicError; end
  
  def self.thumbnail(size, image_id)
    raise NotImplemented.new('Sorry...')
  end
end