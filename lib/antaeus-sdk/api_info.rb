module Antaeus
  module APIInfo
    def self.version(options = {})
      validate_options(options)

      options[:client].get('/info/version')['api']['version']
    end

    def self.status(options = {})
      validate_options(options)

      options[:client].get('/info/status')['api']['status']
    end

    def self.capabilities(options = {})
      validate_options(options)

      options[:client].get('/info/capabilities')['api']['capabilities']
    end

    def self.plugins(options = {})
      validate_options(options)

      options[:client].get('/info/plugins')['api']['plugins']
    end

    def self.metrics(options = {})
      validate_options(options)

      options[:client].get('/info/metrics')['api']['metrics']
    end

    def self.me(options = {})
      validate_options(options)

      options[:client].get('/info/me')['current_user']
    end

    private

    def self.validate_options(options)
      raise Exceptions::InvalidOptions unless options.is_a?(Hash)
      raise Exceptions::MissingAPIClient unless options[:client]
      raise Exceptions::InvalidAPIClient unless options[:client].is_a?(APIClient)
    end
  end
end
