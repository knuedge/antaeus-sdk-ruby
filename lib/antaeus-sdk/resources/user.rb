module Antaeus
  module Resources
    class User < Resource
      property :display_name
      delayed_property { Antaeus.config.user_mail_attribute || :mail }

      path      :all, '/users'
      immutable true

      def memberships
        ResourceCollection.new(
          @client.get("/users/#{id}/memberships")['groups'].collect do |record|
            Group.new(
              entity: record,
              lazy: true,
              tainted: false,
              client: @client
            )
          end,
          type: Antaeus::Resources::Group,
          client: @client
        )
      end

      alias_method :groups, :memberships
    end
  end
end
