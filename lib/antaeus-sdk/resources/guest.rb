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
    end
  end
end
