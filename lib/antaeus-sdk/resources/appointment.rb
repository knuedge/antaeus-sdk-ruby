module Antaeus
  module Resources
    class Appointment < Resource
      property :arrival
      property :comment
      property :contact
      property :departure
      property :location
      property :created_at, read_only: true
      property :arrived?,   read_only: true

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

      # Checkin a Guest
      def checkin
        client = APIClient.instance
        if client.patch("#{path_for(:all)}/#{id}/checkin", {email: guest.email})
          true
        else
          raise 'Exceptions::CheckinFailed'
        end
      end

      # Hidden property used to lookup related resource
      def guest
        Guest.get(@entity['guest_id'])
      end

      def guest=(guest_or_guest_id)
        @entity['guest_id'] = if guest_or_guest_id.is_a?(Guest)
          guest_or_guest_id.id
        else
          guest_or_guest_id
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
