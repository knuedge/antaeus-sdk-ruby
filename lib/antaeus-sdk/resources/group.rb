module Antaeus
  module Resources
    class Group < Resource
      delayed_property { Antaeus.config.group_name_attribute || :cn }

      path      :all, '/groups'
      immutable true

      def members
        client = APIClient.instance
        ResourceCollection.new(
          client.get("#{path_for(:all)}/#{id}/members")['users'].collect do |entity|
            User.new(
              entity,
              lazy: true,
              tainted: false
            )
          end,
          Antaeus::Resources::User
        )
      end

      alias_method :users, :members
    end
  end
end
