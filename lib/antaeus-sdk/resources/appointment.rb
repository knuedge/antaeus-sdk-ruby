module Antaeus
  module Resources
    class Appointment < Resource
      property :arrival
      property :comment
      property :contact
      property :departure
      property :location
      property :created_at

      path :all, '/appointments'

      def self.upcoming
        client = APIClient.instance
        ResourceCollection.new(
          client.get("#{path_for(:all)}/upcoming")['appointments'].collect do |entity|
            self.new(
              entity,
              lazy: true,
              tainted: false
            )
          end,
          self
        )
      end

      # Hidden property used to lookup related resource
      def guest
        Guest.new(@entity['guest'], lazy: true, tainted: false)
      end

      def guest=(guest_name)
        @entity['guest_id'] = if guest_name.is_a?(Guest)
          Guest.id
        else
          guest_name
        end
        @tainted = true
      end

      def user
        User.get(contact)
      end

      def user=(username)
        contact = if username.is_a?(User)
          username.id
        else
          username
        end
        @tainted = true
      end
    end
  end
end
