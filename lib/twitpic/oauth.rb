module Twitpic
  class OAuth
    AUTH_PROVIDER_URL = 'https://api.twitter.com/1/account/verify_credentials.json'
    REALM = 'http://api.twitter.com/'
    
    def initialize(consumer_key, consumer_secret)
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @signature_method = 'HMAC-SHA1'
    end
    
    def authorize(access_token, access_secret)
      @access_token = access_token
      @access_secret = access_secret
    end
    
    def get(url, headers = {})
      raise NotImplemented.new('Sorry')
    end

    def head(url, headers = {})
      raise NotImplemented.new('Sorry')
    end

    def post(url, body = nil, headers = {})
      method = method.to_s
      uri = URI.parse(url)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = body
      headers.each_pair {|k,v| request[k] = v}
      
      # add headers for OAuth Echo
      auth = make_auth_header(:GET, AUTH_PROVIDER_URL)
      request['X-Auth-Service-Provider'] = AUTH_PROVIDER_URL
      request['X-Verify-Credentials-Authorization'] = "#{auth}, realm=\"#{REALM}\""
      
      
      begin
        http = Net::HTTP.new(uri.host, uri.port).start
        response = http.request(request)
        return response.body
      rescue Errno::ECONNRESET
        raise HttpError.new("ERROR: Connection reset by peer")
        return
      rescue Errno::ETIMEDOUT
        raise HttpError.new("ERROR: Connection Timeout(Errno::ETIMEDOUT)")
        return
      rescue Timeout::Error
        raise HttpError.new("ERROR: Connection Timeout(Timeout::Error)")
        return
      end
    end

    def put(url, body = nil, headers = {})
      raise NotImplemented.new('Sorry')
    end

    def delete(url, headers = {})
      raise NotImplemented.new('Sorry')
    end
    
    private
      
      def make_auth_header(method, url, body = nil)
        method = method.to_s
        uri = URI.parse(url)
        request_body = body.is_a?(Hash) ? encode_parameters(body) : body.to_s
        auth = auth_header(method, uri, request_body)
        
        return auth
      end

      RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/

      def escape(value)
        URI.escape(value.to_s, RESERVED_CHARACTERS)
      end

      def encode_parameters(params, delimiter = '&', quote = nil)
        if params.is_a?(Hash)
          params = params.map do |key, value|
            "#{escape(key)}=#{quote}#{escape(value)}#{quote}"
          end
        else
          params = params.map { |value| escape(value) }
        end
        delimiter ? params.join(delimiter) : params
      end

      VERSION = '0.1'
      USER_AGENT = "SimpleOAuth/#{VERSION}"

      def create_http_request(method, path, body, headers)
        method = method.capitalize.to_sym
        request = Net::HTTP.const_get(method).new(path, headers)
        request['User-Agent'] = USER_AGENT
        if method == :Post || method == :Put
          request.body = body.is_a?(Hash) ? encode_parameters(body) : body.to_s
          request.content_type = 'application/x-www-form-urlencoded'
          request.content_length = (request.body || '').length
        end
        request
      end

      def auth_header(method, url, body)
        parameters = oauth_parameters
        parameters[:oauth_signature] = signature(method, url, body, parameters)
        'OAuth ' + encode_parameters(parameters, ', ', '"')
      end

      OAUTH_VERSION = '1.0'

      def oauth_parameters
        {
          :oauth_consumer_key => @consumer_key,
          :oauth_token => @access_token,
          :oauth_signature_method => @signature_method,
          :oauth_timestamp => timestamp,
          :oauth_nonce => nonce,
          :oauth_version => OAUTH_VERSION
        }
      end

      def timestamp
        Time.now.to_i.to_s
      end

      def nonce
        OpenSSL::Digest::Digest.hexdigest('MD5', "#{Time.now.to_f}#{rand}")
      end

      def signature(*args)
        base64(digest_hmac_sha1(signature_base_string(*args)))
      end

      def base64(value)
        [ value ].pack('m').gsub(/\n/, '')
      end

      def digest_hmac_sha1(value)
        OpenSSL::HMAC.digest(OpenSSL::Digest::SHA1.new, secret, value)
      end

      def secret
        escape(@consumer_secret) + '&' + escape(@access_secret)
      end

      def signature_base_string(method, url, body, parameters)
        method = method.upcase
        base_url = signature_base_url(url)
        parameters = normalize_parameters(parameters, body, url.query)
        encode_parameters([ method, base_url, parameters ])
      end

      def signature_base_url(url)
        URI::HTTP.new(url.scheme, url.userinfo, url.host, nil, nil, url.path,
                      nil, nil, nil)
      end

      def normalize_parameters(parameters, body, query)
        parameters = encode_parameters(parameters, nil)
        parameters += body.split('&') if body
        parameters += query.split('&') if query
        parameters.sort.join('&')
      end
  end
end