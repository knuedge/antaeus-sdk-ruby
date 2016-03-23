module Antaeus
  class APIClient
    include Singleton

    def authenticate
      return true if authenticated?
      begin
        raw_token_data = RestClient.post(
          "#{Antaeus.config.base_url}/users/authenticate",
          { login: Antaeus.config.login, password: Antaeus.config.password }.to_json,
          content_type: :json,
          accept: :json
        )
        token_data = JSON.load(raw_token_data)
        Antaeus.config.api_token = token_data['api_token']
        true
      rescue RestClient::Exception => e
        # TODO make this an actual exception
        fail "Exceptions::AuthenticationFailure: #{e.response}"
      end
    end

    def authenticated?
      Antaeus.config.api_token ? true : false
    end

    def connect
      return true if connected?

      if authenticate
        @rest_client = RestClient::Resource.new(
          Antaeus.config.base_url,
          content_type: :json,
          accept: :json,
          headers: {
            :'X-Api-Token:' => Antaeus.config.api_token
          }
        )
      end
    end

    def connected?
      @rest_client ? true : false
    end

    def raw
      @rest_client
    end

    def get(uri)
      if connect
        JSON.load(raw[uri].get)
      end
    end
  end
end
