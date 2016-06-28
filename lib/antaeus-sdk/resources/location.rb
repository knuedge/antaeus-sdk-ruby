module Antaeus
  module Resources
    class Location < Resource
      property :shortname
      property :address_line1
      property :address_line2
      property :city
      property :state
      property :zip
      property :country
      property :phone
      property :details
      property :public_details
      property :email_instructions
      property :created_at, read_only: true, type: :time

      path :all, '/locations'

      def appointments
        ResourceCollection.new(
          @client.get("#{path_for(:all)}/#{id}/appointments?all=true")['appointments'].collect do |record|
            Appointment.new(
              entity: record,
              lazy: true,
              tainted: false,
              client: @client
            )
          end,
          type: Antaeus::Resources::Appointment,
          client: @client
        )
      end

      def upcoming_appointments
        ResourceCollection.new(
          @client.get("#{path_for(:all)}/#{id}/appointments")['appointments'].collect do |record|
            Appointment.new(
              entity: record,
              lazy: true,
              tainted: false,
              client: @client
            )
          end,
          type: Antaeus::Resources::Appointment,
          client: @client
        )
      end
    end
  end
end
