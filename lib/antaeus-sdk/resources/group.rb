module Antaeus
  module Resources
    class Group < Resource
      delayed_property { Antaeus.config.group_name_attribute || :cn }

      path :all, '/groups'
    end
  end
end
