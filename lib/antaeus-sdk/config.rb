# A generic way of constructing a mergeable configuration
class Antaeus::Config < OpenStruct
  # Construct a base config using the following order of precedence:
  #   * environment variables
  #   * YAML file
  #   * defaults
  def load
    # First, apply the defaults
    defaults = {
      group_name_attribute: :cn,
      user_login_attribute: :uid,
      user_firstname_attribute: :givenName,
      user_lastname_attribute: :sn,
      user_mail_attribute: :mail,
      base_url: 'http://localhost:8080',
      login: 'username',
      password: 'p@assedWard!'
    }
    merge defaults

    # Then apply the config file, if one exists
    apprc_dir = File.expand_path(File.join('~', '.antaeus'))
    config_file = File.expand_path(File.join(apprc_dir, 'client.yml'))

    merge YAML.load_file(config_file) if File.readable?(config_file)

    # Finally, apply any environment variables specified
    env_conf = {}
    defaults.keys.each do |key|
      antaeus_key = "ANTAEUS_#{key}".upcase
      env_conf[key] = ENV[antaeus_key] if ENV.key?(antaeus_key)
    end
    merge env_conf unless env_conf.empty?
  end

  def merge(data)
    raise Exceptions::InvalidConfigData unless data.is_a?(Hash)
    data.each do |k, v|
      self[k.to_sym] = v
    end
  end
end

# Make the config available as a singleton
module Antaeus
  class << self
    def config
      @config ||= Config.new
    end
  end
end
