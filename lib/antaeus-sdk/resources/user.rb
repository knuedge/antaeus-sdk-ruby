module Antaeus
  module Resources
    class User < Resource
      delayed_property { Antaeus.config.user_mail_attribute || :mail }

      path      :all, '/users'
      immutable true

      def memberships
        client = APIClient.instance
        ResourceCollection.new(
          client.get("/users/#{id}/memberships")['groups'].collect do |entity|
            Group.new(
              entity,
              lazy: true,
              tainted: false
            )
          end,
          Antaeus::Resources::Group
        )
      end

      alias_method :groups, :memberships
    end
  end
end
