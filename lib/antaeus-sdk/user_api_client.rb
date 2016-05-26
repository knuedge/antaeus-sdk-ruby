module Antaeus
  class UserAPIClient < APIClient
    def authenticate(login, pass)
      @login ||= login
      begin
        raw_token_data = RestClient.post(
          "#{Antaeus.config.base_url}/users/authenticate",
          { login: @login, password: pass }.to_json,
          content_type: :json,
          accept: :json
        )
        token_data = JSON.load(raw_token_data)
        set_token(@login, token_data['api_token'])
        true
      rescue RestClient::Exception => e
        raise Exceptions::AuthenticationFailure, e.response
      end
    end

    # Set the token in memory for the given user
    def set_token(login, token)
      # this should probably be improved to handle race conditions
      @login ||= login
      Antaeus.config.logins ||= {}
      Antaeus.config.logins[login] ||= {}
      Antaeus.config.logins[login][:token] = token
    end

    def authenticated?
      if @login && Antaeus.config.logins[@login] && Antaeus.config.logins[@login][:token]
        true
      else
        false
      end
    end

    def connect
      return true if connected?

      if authenticated?
        @rest_client = RestClient::Resource.new(
          Antaeus.config.base_url,
          content_type: :json,
          accept: :json,
          headers: {
            'X-API-Token:': Antaeus.config.logins[@login][:token]
          }
        )
      else
        raise Exceptions::LoginRequired
      end
    end
  end
end
