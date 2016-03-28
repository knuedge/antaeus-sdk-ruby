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
      property :created_at

      path :all, '/guests'

      def appointments
        client = APIClient.instance
        ResourceCollection.new(
          client.get("#{path_for(:all)}/#{id}/appointments")['appointments'].collect do |entity|
            Appointment.new(
              entity,
              lazy: true,
              tainted: false
            )
          end,
          Antaeus::Resources::Appointment
        )
      end

      def available_appointments(location)
      end

      def verify(email, pin)
      end

      def upcoming_appointments
      end
    end
  end
end
