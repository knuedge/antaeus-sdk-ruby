module Antaeus
  module Resources
    class Guest < Resource
      property :email
      property :full_name
      property :phone
      property :citizenship
      property :need_nda

      path :all, '/guests'
    end
  end
end
