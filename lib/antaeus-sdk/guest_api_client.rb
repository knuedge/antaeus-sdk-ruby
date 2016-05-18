module Antaeus
  class GuestAPIClient < APIClient
    def authenticate(guest, pin)
      @guest ||= guest
      Antaeus.config.guest ||= {}
      Antaeus.config.guest[@guest] ||= {}
      begin
        raw_token_data = RestClient.post(
          "#{Antaeus.config.base_url}/guests/login",
          { email: @guest, pin: pin }.to_json,
          content_type: :json,
          accept: :json
        )
        token_data = JSON.load(raw_token_data)
        Antaeus.config.guest[@guest][:token] = token_data['guest_token']
        true
      rescue RestClient::Exception => e
        raise Exceptions::AuthenticationFailure, e.response
      end
    end

    def authenticated?
      if @guest && Antaeus.config.guest[@guest] && Antaeus.config.guest[@guest][:token]
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
            'X-Guest-Token:': Antaeus.config.guest[@guest][:token]
          }
        )
      else
        raise Exceptions::LoginRequired
      end
    end
  end
end