module Antaeus
  module Resources
    class Hook < Resource
      property :name
      property :plugins
      property :configurations
      property :created_at, read_only: true, type: :time

      path :all, '/hooks'

      def self.all_available(options = {})
        validate_options(options)
        options[:client].get("#{path_for(:all)}/available")['available_hooks']
      end
    end
  end
end
