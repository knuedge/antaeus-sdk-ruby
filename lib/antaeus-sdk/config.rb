class Antaeus::Config < OpenStruct
end
  
module Antaeus
  class << self
    def config
      @config ||= Config.new
    end
  end
end
