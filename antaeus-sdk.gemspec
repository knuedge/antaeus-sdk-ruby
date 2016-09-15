lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'antaeus-sdk/version'

Gem::Specification.new do |s|
  s.name        = 'antaeus-sdk'
  s.version     = Antaeus::SDK.version
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = 'Antaeus Guest Management SDK'
  s.description = 'The Ruby SDK for the Antaeus Guest Management SDK'
  s.authors     = ['Jonathan Gnagy']
  s.email       = 'jgnagy@knuedge.com'
  s.required_ruby_version = '~> 2.0'
  s.files       = [
    'bin/antaeus-cli',
    'lib/antaeus-sdk.rb',
    'lib/antaeus-sdk/api_client.rb',
    'lib/antaeus-sdk/api_info.rb',
    'lib/antaeus-sdk/config.rb',
    'lib/antaeus-sdk/exception.rb',
    'lib/antaeus-sdk/exceptions/approval_change_failed.rb',
    'lib/antaeus-sdk/exceptions/authentication_failure.rb',
    'lib/antaeus-sdk/exceptions/checkin_change_failed.rb',
    'lib/antaeus-sdk/exceptions/checkout_change_failed.rb',
    'lib/antaeus-sdk/exceptions/immutable_instance.rb',
    'lib/antaeus-sdk/exceptions/immutable_modification.rb',
    'lib/antaeus-sdk/exceptions/invalid_api_client.rb',
    'lib/antaeus-sdk/exceptions/invalid_config_data.rb',
    'lib/antaeus-sdk/exceptions/invalid_entity.rb',
    'lib/antaeus-sdk/exceptions/invalid_input.rb',
    'lib/antaeus-sdk/exceptions/invalid_options.rb',
    'lib/antaeus-sdk/exceptions/invalid_property.rb',
    'lib/antaeus-sdk/exceptions/invalid_where_query.rb',
    'lib/antaeus-sdk/exceptions/login_required.rb',
    'lib/antaeus-sdk/exceptions/missing_api_client.rb',
    'lib/antaeus-sdk/exceptions/missing_entity.rb',
    'lib/antaeus-sdk/exceptions/missing_path.rb',
    'lib/antaeus-sdk/exceptions/new_instance_with_id.rb',
    'lib/antaeus-sdk/guest_api_client.rb',
    'lib/antaeus-sdk/helpers/string.rb',
    'lib/antaeus-sdk/resource.rb',
    'lib/antaeus-sdk/resource_collection.rb',
    'lib/antaeus-sdk/resources/appointment.rb',
    'lib/antaeus-sdk/resources/guest.rb',
    'lib/antaeus-sdk/resources/group.rb',
    'lib/antaeus-sdk/resources/hook.rb',
    'lib/antaeus-sdk/resources/location.rb',
    'lib/antaeus-sdk/resources/remote_application.rb',
    'lib/antaeus-sdk/resources/user.rb',
    'lib/antaeus-sdk/user_api_client.rb',
    'lib/antaeus-sdk/version.rb',
    'LICENSE'
  ]
  s.executables << 'antaeus-cli'
  s.bindir      = 'bin'
  s.license     = 'MIT'
  s.platform    = Gem::Platform::RUBY
  s.post_install_message = 'Thanks for installing the Antaeus Ruby SDK!'
  s.homepage    = 'https://stash.intellisis.com/projects/ITS/repos/antaeus-sdk-ruby/browse'

  # Dependencies
  s.add_runtime_dependency 'crypt',       '~> 2.2'
  s.add_runtime_dependency 'rest-client', '~> 1.8'
  s.add_runtime_dependency 'linguistics', '~> 2.1'
  s.add_runtime_dependency 'pry',         '~> 0.10'
  s.add_runtime_dependency 'addressable', '~> 2.4'
  s.add_runtime_dependency 'will_paginate', '~> 3.1'

  s.add_development_dependency 'rspec',   '~> 3.1'
  s.add_development_dependency 'rubocop', '~> 0.35'
  s.add_development_dependency 'yard',    '~> 0.8'
end
