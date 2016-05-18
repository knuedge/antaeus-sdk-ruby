module Antaeus
  module Resources
    class Group < Resource
      delayed_property { Antaeus.config.group_name_attribute || :cn }

      path      :all, '/groups'
      immutable true

      def members
        ResourceCollection.new(
          @client.get("#{path_for(:all)}/#{id}/members")['users'].collect do |record|
            User.new(
              entity: record,
              lazy: true,
              tainted: false,
              client: @client
            )
          end,
          type: Antaeus::Resources::User,
          client: @client
        )
      end

      alias_method :users, :members
    end
  end
end
