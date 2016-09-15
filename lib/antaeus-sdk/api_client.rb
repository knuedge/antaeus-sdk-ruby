module Antaeus
  # This class is the actual API client, which is a smart wrapper around RestClient
  class APIClient
    def self.instance
      new
    end

    def initialize
    end

    # override this method
    def authenticate(login, pass)
      false
    end

    # override this method
    def authenticated?
      false
    end

    # override this method
    def connect
      false
    end

    def connected?
      @rest_client ? true : false
    end

    def delete(uri)
      client_action do
        raw[Addressable::URI.escape(uri)].delete
      end
    end

    def get(uri, data = nil)
      client_action do
        if data
          JSON.load raw[Addressable::URI.escape(uri)].get(params: data)
        else
          JSON.load raw[Addressable::URI.escape(uri)].get
        end
      end
    end

    def post(uri, data)
      client_action do
        JSON.load raw[Addressable::URI.escape(uri)].post(json_escape(data.to_json))
      end
    end

    def patch(uri, data)
      client_action do
        response = raw[Addressable::URI.escape(uri)].patch(json_escape(data.to_json))
        if response && !response.empty?
          JSON.load(response)
        else
          true
        end
      end
    end

    def put(uri, data)
      client_action do
        raw[Addressable::URI.escape(uri)].put(json_escape(data.to_json))
      end
    end

    def raw
      @rest_client
    end

    # This needs to be caught by whatever is using the SDK to get new user creds
    def refresh_token
      @rest_client = nil
      raise Exceptions::LoginRequired
    end

    private

    def json_escape(s)
      json_escape = {
        '&' => '\u0026',
        '>' => '\u003e',
        '<' => '\u003c',
        '%' => '\u0025',
        "\u2028" => '\u2028',
        "\u2029" => '\u2029'
      }
      json_escape_regex = /[\u2028\u2029&><%]/u

      s.to_s.gsub(json_escape_regex, json_escape)
    end

    def client_action(&block)
      begin
        yield if connect
      rescue RestClient::Exception => e
        raise e, e.response unless e.http_code == 401 # This rescue only helps with token refreshing
        refresh_token
        yield if connect
      end
    end # client_action()
  end
end
