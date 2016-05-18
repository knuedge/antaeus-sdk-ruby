# Standard Library requirements
require 'fileutils'
require 'base64'
require 'yaml'
require 'json'
require 'ostruct'
require 'singleton'
require 'uri'
require 'linguistics'
Linguistics.use(:en)

# External Requirements
require 'crypt/blowfish'
require 'rest-client'

# Internal Requirements
require 'antaeus-sdk/helpers/string'
include Antaeus::Helpers

require 'antaeus-sdk/exception'
require 'antaeus-sdk/exceptions/approval_change_failed'
require 'antaeus-sdk/exceptions/authentication_failure'
require 'antaeus-sdk/exceptions/checkin_failed'
require 'antaeus-sdk/exceptions/immutable_instance'
require 'antaeus-sdk/exceptions/immutable_modification'
require 'antaeus-sdk/exceptions/invalid_api_client'
require 'antaeus-sdk/exceptions/invalid_config_data'
require 'antaeus-sdk/exceptions/invalid_entity'
require 'antaeus-sdk/exceptions/invalid_input'
require 'antaeus-sdk/exceptions/invalid_options'
require 'antaeus-sdk/exceptions/invalid_property'
require 'antaeus-sdk/exceptions/invalid_where_query'
require 'antaeus-sdk/exceptions/login_required'
require 'antaeus-sdk/exceptions/missing_api_client'
require 'antaeus-sdk/exceptions/missing_entity'
require 'antaeus-sdk/exceptions/missing_path'
require 'antaeus-sdk/exceptions/new_instance_with_id'
require 'antaeus-sdk/config'
Antaeus.config.load # Load config before requiring other classes

require 'antaeus-sdk/api_client'
require 'antaeus-sdk/guest_api_client'
require 'antaeus-sdk/user_api_client'
require 'antaeus-sdk/resource'
require 'antaeus-sdk/resource_collection'
require 'antaeus-sdk/resources/appointment'
require 'antaeus-sdk/resources/guest'
require 'antaeus-sdk/resources/group'
require 'antaeus-sdk/resources/remote_application'
require 'antaeus-sdk/resources/user'
