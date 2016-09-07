module Antaeus
  module Resources
    class Appointment < Resource
      property :arrival,    type: :time
      property :comment
      property :contact
      property :departure,  type: :time
      property :location_id
      property :guest_id
      property :created_at, read_only: true, type: :time
      property :created_by, read_only: true
      property :arrived?,   read_only: true
      property :approved?,  read_only: true
      property :departed?,  read_only: true

      path :all, '/appointments'

      # A collection of all upcoming appointments
      def self.upcoming(options = {})
        validate_options(options)
        ResourceCollection.new(
          options[:client].get("#{path_for(:all)}/upcoming")['appointments'].collect do |record|
            self.new(
              entity: record,
              lazy: true,
              tainted: false,
              client: options[:client]
            )
          end,
          type: self,
          client: options[:client]
        )
      end

      # Generate a report of appointments based on some criteria
      def self.report(options = {})
        validate_options(options)
        ResourceCollection.new(
          options[:client].post("/reports/generate", q: options[:criteria])['appointments'].collect do |record|
            self.new(
              entity: record,
              lazy: false,
              tainted: false,
              client: options[:client]
            )
          end,
          type: self,
          client: options[:client]
        )
      end

      # Approve an Appointment
      def approve
        if @client.patch("#{path_for(:all)}/#{id}/approve", approve: true)
          true
        else
          fail Exceptions::ApprovalChangeFailed
        end
        reload
        return true
      end

      # Checkin a Guest
      def checkin
        if @client.patch("#{path_for(:all)}/#{id}/checkin", email: guest.email)
          true
        else
          raise Exceptions::CheckinChangeFailed
        end
        reload
        return true
      end

      # Checkout a Guest
      def checkout
        if @client.patch("#{path_for(:all)}/#{id}/checkout", email: guest.email)
          true
        else
          raise Exceptions::CheckoutChangeFailed
        end
        reload
        return true
      end

      # Hidden property used to lookup related resource
      def guest
        Guest.get(@entity['guest_id'], client: @client)
      end

      # Set the guest associated with this appointment
      def guest=(guest_or_guest_id)
        @entity['guest_id'] = if guest_or_guest_id.is_a?(Guest)
          guest_or_guest_id.id
        else
          guest_or_guest_id
        end
        @tainted = true
      end

      # Hidden property used to lookup related resource
      def location
        Location.get(@entity['location_id'], client: @client)
      end

      # Set the location associated with this appointment
      def location=(location_or_location_id)
        @entity['location_id'] = if location_or_location_id.is_a?(Location)
          location_or_location_id.id
        else
          location_or_location_id
        end
        @tainted = true
      end

      # Unapprove an Appointment
      def unapprove
        if @client.patch("#{path_for(:all)}/#{id}/approve", approve: false)
          true
        else
          fail Exceptions::ApprovalChangeFailed
        end
        reload
        return true
      end

      # Checkin a Guest
      def undo_checkin
        if @client.delete("#{path_for(:all)}/#{id}/checkin")
          true
        else
          raise Exceptions::CheckinChangeFailed
        end
        reload
        return true
      end

      # Checkout a Guest
      def undo_checkout
        if @client.delete("#{path_for(:all)}/#{id}/checkout")
          true
        else
          raise Exceptions::CheckoutChangeFailed
        end
        reload
        return true
      end

      # User related to an appointment
      def user
        User.get(contact, client: @client)
      end

      # Set the user related to an appointment
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
