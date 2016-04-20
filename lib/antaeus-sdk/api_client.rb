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
        fail Exceptions::AuthenticationFailure,  e.response
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
            :'X-API-Token:' => Antaeus.config.api_token
          }
        )
      end
    end

    def connected?
      @rest_client ? true : false
    end

    def delete(uri)
      client_action do
        raw[uri].delete
      end
    end

    def get(uri)
      client_action do
        JSON.load raw[uri].get
      end
    end

    def post(uri, data)
      client_action do
        JSON.load raw[uri].post(data.to_json)
      end
    end

    def patch(uri, data)
      client_action do
        response = raw[uri].patch(data.to_json)
        if response && !response.empty?
          JSON.load(response)
        else
          true
        end
      end
    end

    def put(uri, data)
      client_action do
        raw[uri].put data.to_json
      end
    end

    def raw
      @rest_client
    end

    def refresh_token
      Antaeus.config.api_token = nil
      @rest_client = nil
      connect
    end

    private

    def client_action(&block)
      begin
        if connect
          block.call
        end
      rescue RestClient::Exception => e
        if e.http_code == 401
          refresh_token
          if connect
            block.call
          end
        else
          fail e
        end
      end
    end

  end
end
