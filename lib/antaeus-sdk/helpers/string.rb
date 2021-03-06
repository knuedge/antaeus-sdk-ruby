# Helpers for manipulating Strings
module Antaeus
  module Helpers
    # Convert CamelCase to underscored_text
    # @return [String]
    def to_underscore(string)
      string.gsub(/::/, '/')
            .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .tr('-', '_')
            .downcase
    end

    # Convert underscored_text to CamelCase
    # @return [String]
    def to_camel(string)
      string.split('_').map(&:capitalize).join
    end

    def humanize(string)
      string.to_s.gsub(/_id$/, "").gsub(/_/, " ").capitalize
    end
  end
end
