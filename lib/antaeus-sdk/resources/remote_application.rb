module Antaeus
  module Resources
    class RemoteApplication < Resource
      property :app_name
      property :ident
      property :app_key
      property :url
      property :created_at, read_only: true

      path :all, '/remote_applications'
    end
  end
end
