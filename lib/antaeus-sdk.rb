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
require 'antaeus-sdk/exceptions/authentication_failure'
require 'antaeus-sdk/exceptions/invalid_property'
require 'antaeus-sdk/exceptions/missing_path'
require 'antaeus-sdk/config'
Antaeus.config.load # Load config before requiring other classes

require 'antaeus-sdk/api_client'
require 'antaeus-sdk/resource'
require 'antaeus-sdk/resource_collection'
require 'antaeus-sdk/resources/guest'
require 'antaeus-sdk/resources/group'
