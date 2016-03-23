module Antaeus
  module Resources
    class User < Resource
      delayed_property { Antaeus.config.user_mail_attribute || :mail }

      path :all, '/users'
      path :search, '/users/search'
    end
  end
end
