module Antaeus
  module Resources
    class Guest < Resource
      property :email
      property :full_name
      property :phone
      property :citizenship
      property :need_nda
      property :signed_nda
      property :need_tcpa
      property :signed_tcpa
      property :pin
      property :created_at, read_only: true, type: :time

      path :all, '/guests'

      def appointments
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

      def available_appointments(location)
      end

      def upcoming_appointments
      end
    end
  end
end
