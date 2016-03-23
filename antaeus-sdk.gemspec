Gem::Specification.new do |s|
  s.name        = 'antaeus-sdk'
  s.version     = "0.0.1"
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = "Antaeus Guest Management SDK"
  s.description = "The Ruby SDK for the Antaeus Guest Management SDK"
  s.authors     = ["Jonathan Gnagy"]
  s.email       = 'jgnagy@intellisis.com'
  s.required_ruby_version = '~> 2.0'
  s.files       = [
    "lib/antaeus-sdk.rb",
    "lib/antaeus-sdk/resource.rb",
    "lib/antaeus-sdk/resources/guest.rb",
    "LICENSE",
    "README.md"
  ]
  s.license     = 'MIT'
  s.platform    = Gem::Platform::RUBY
  s.post_install_message = "Thanks for installing the Antaeus Ruby SDK!"
  s.homepage    = "https://stash.intellisis.com/projects/ITS/repos/antaeus-sdk-ruby/browse"

  # Dependencies
  s.add_runtime_dependency 'crypt',       '~> 2.2'
  s.add_runtime_dependency 'rest-client', '~> 1.8'
  s.add_runtime_dependency 'linguistics', '~> 2.1'

  s.add_development_dependency 'rspec',   '~> 3.1'
  s.add_development_dependency 'pry',     '~> 0.10'
  s.add_development_dependency 'rubocop', '~> 0.35'
  s.add_development_dependency 'yard',    '~> 0.8'
end
