module Antaeus
  module Resources
    class Group < Resource
      property :cn
      property :member

      path :all, '/groups'
    end
  end
end
