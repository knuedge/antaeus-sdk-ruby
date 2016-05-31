module Antaeus
  module APIInfo
    def self.version(options = {})
      validate_options(options)

      options[:client].get('/info/version')['api']['version']
    end

    def self.status
      validate_options(options)

      options[:client].get('/info/status')['api']['status']
    end

    def self.capabilities
      validate_options(options)

      options[:client].get('/info/capabilities')['api']['capabilities']
    end

    def self.metrics
      validate_options(options)

      options[:client].get('/info/capabilities')['api']['capabilities']
    end

    private

    def self.validate_options(options)
      raise Exceptions::InvalidOptions unless options.is_a?(Hash)
      raise Exceptions::MissingAPIClient unless options[:client]
      raise Exceptions::InvalidAPIClient unless options[:client].is_a?(APIClient)
    end
  end
end
