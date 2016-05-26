module Antaeus
  class GuestAPIClient < APIClient
    def authenticate(guest, pin)
      @guest ||= guest
      begin
        raw_token_data = RestClient.post(
          "#{Antaeus.config.base_url}/guests/login",
          { email: @guest, pin: pin }.to_json,
          content_type: :json,
          accept: :json
        )
        token_data = JSON.load(raw_token_data)
        set_token(@guest, token_data['guest_token'])
        true
      rescue RestClient::Exception => e
        raise Exceptions::AuthenticationFailure, e.response
      end
    end

    # Set the token in memory for the given guest
    def set_token(guest, token)
      # this should probably be improved to handle race conditions
      @guest ||= guest
      @guest_data ||= {}
      @guest_data[guest] ||= {}
      @guest_data[guest][:token] = token
    end

    def authenticated?
      if @guest && @guest_data[@guest] && @guest_data[@guest][:token]
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
            'X-Guest-Token:': @guest_data[@guest][:token]
          }
        )
      else
        raise Exceptions::LoginRequired
      end
    end
  end
end
