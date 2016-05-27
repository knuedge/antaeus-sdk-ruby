module Antaeus
  # A generic API resource
  class Resource
    attr_accessor :client
    attr_reader :errors
    include Comparable

    def self.properties
      @properties ||= {}
    end

    # Delayed properties are evaluated when an instance is created
    # WARNING: Sanity checking of the end-result isn't possible. Use with care
    def self.delayed_property(options = {}, &block)
      @properties ||= {}

      @properties[block] = options
    end

    # Can this type of resource be changed client-side?
    def self.immutable(status)
      unless status.is_a?(TrueClass) || status.is_a?(FalseClass)
        raise Exceptions::InvalidInput
      end
      @immutable = status
    end

    # Check if a resource class is immutable
    def self.immutable?
      @immutable ||= false
    end

    # Define a property for a model
    # TODO: add more validations on options and names
    def self.property(name, options = {})
      @properties ||= {}

      invalid_prop_names = [
        :>, :<, :'=', :class, :def,
        :%, :'!', :/, :'.', :'?', :*, :'{}',
        :'[]'
      ]
      
      raise(Exception::InvalidProperty) if invalid_prop_names.include?(name.to_sym)
      @properties[name.to_sym] = options
    end

    def self.path(kind, uri)
      @paths ||= {}
      @paths[kind.to_sym] = uri
    end

    def self.paths
      @paths ||= {}
    end

    def self.path_for(kind)
      paths[kind.to_sym]
    end

    def self.gen_property_methods
      properties.each do |prop, opts|
        if prop.is_a?(Proc)
          prop = prop.call.to_s.to_sym
        end

        # Getter methods
        define_method(prop) do
          if @lazy && !@entity.key?(prop.to_s)
            reload
          end
          if opts[:type] && opts[:type] == :time
            @entity[prop.to_s] ? Time.parse(@entity[prop.to_s]) : nil
          else
            @entity[prop.to_s]
          end
        end

        # Setter methods (don't make one for obviously read-only properties)
        unless prop.match /\?$/ || opts[:read_only]
          define_method("#{prop}=".to_sym) do |value|
            raise Exceptions::ImmutableModification if immutable?
            @entity[prop.to_s] = value
            @tainted = true
          end
        end
      end
    end

    def self.all(options = {})
      validate_options(options)
      options[:lazy] = true unless options.key?(:lazy)

      # TODO: add validation checks for the required pieces
      fail(Exceptions::MissingPath) unless path_for(:all)

      root = to_underscore(self.name.split('::').last.en.plural)
      this_path = options[:lazy] ? path_for(:all) : "#{path_for(:all)}?lazy=false"

      ResourceCollection.new(
        options[:client].get(this_path)[root].collect do |record|
          self.new(
            entity: record,
            lazy: (options[:lazy] ? true : false),
            tainted: false,
            client: options[:client]
          )
        end,
        type: self,
        client: options[:client]
      )
    end

    def self.get(id, options = {})
      validate_options(options)
      fail(Exceptions::MissingPath) unless path_for(:all)

      root = to_underscore(self.name.split('::').last)
      self.new(
        entity: options[:client].get("#{path_for(:all)}/#{id}")[root],
        lazy: false,
        tainted: false,
        client: options[:client]
      )
    end

    def self.where(attribute, value, options = {})
      validate_options(options)
      options[:comparison] ||= '=='
      all(lazy: false, client: options[:client]).where(attribute, value, comparison: options[:comparison])
    end

    def destroy
      fail Exceptions::ImmutableInstance if immutable?
      unless new?
        @client.delete("#{path_for(:all)}/#{id}")
        @lazy = false
        @tainted = true
        @entity.delete('id')
      end
      true
    end

    def fresh?
      !tainted?
    end

    # ActiveRecord ActiveModel::Name compatibility method
    def self.human
      humanize(i18n_key)
    end

    # ActiveRecord ActiveModel::Name compatibility method
    def self.i18n_key
      to_underscore(self.name.split('::').last)
    end

    def id
      @entity['id']
    end

    def immutable?
      self.class.immutable?
    end

    def initialize(options = {})
      raise Exceptions::InvalidOptions unless options.is_a?(Hash)
      raise Exceptions::MissingAPIClient unless options[:client]
      raise Exceptions::InvalidAPIClient unless options[:client].is_a?(APIClient)

      if options[:entity]
        raise Exceptions::MissingEntity unless options[:entity]
        raise Exceptions::InvalidEntity unless options[:entity].is_a?(Hash)
        @entity = options[:entity]
      else
        @entity  = {}
      end
      # Allows lazy-loading if we're told this is a lazy instance
      #  This means only the minimal attributes were fetched.
      #  This shouldn't be set by end-users.
      @lazy    = options.key?(:lazy) ? options[:lazy] : false
      # This allows local, user-created instances to be differentiated from fetched
      # instances from the backend API. This shouldn't be set by end-users.
      @tainted = options.key?(:tainted) ? options[:tainted] : true
      # This is the API Client used to get data for this resource
      @client  = options[:client]
      @errors  = {}

      if immutable? && @tainted
        raise Exceptions::ImmutableInstance
      end

      # The 'id' field should not be set manually
      if @entity.key?('id')
        raise Exceptions::NewInstanceWithID unless !@tainted
      end

      self.class.class_eval do
        gen_property_methods
      end
    end

    # ActiveRecord ActiveModel::Name compatibility method
    def model_name
      self.class
    end

    def new?
      !@entity.key?('id')
    end

    # ActiveRecord ActiveModel::Name compatibility method
    def self.param_key
      singular_route_key.to_sym
    end

    def paths
      self.class.paths
    end

    def path_for(kind)
      self.class.path_for(kind)
    end

    # ActiveRecord ActiveModel::Model compatibility method
    def persisted?
      !new?
    end

    def reload
      root = to_underscore(self.class.name.split('::').last)

      if new?
        # Can't reload a new resource
        false
      else
        @entity  = @client.get("#{path_for(:all)}/#{id}")[root]
        @lazy    = false
        @tainted = false
        true
      end
    end

    # ActiveRecord ActiveModel::Name compatibility method
    def self.route_key
      singular_route_key.en.plural
    end

    # ActiveRecord ActiveModel::Name compatibility method
    def self.singular_route_key
      to_underscore(self.name.split('::').last)
    end

    def save
      root = to_underscore(self.class.name.split('::').last)

      if new?
        @entity  = @client.post("#{path_for(:all)}", @entity)[root]
        @lazy    = false
      else
        @client.put("#{path_for(:all)}/#{id}", @entity)
      end
      @tainted = false
      true
    end

    def self.search(query, options = {})
      validate_options(options)
      is_lazy = options.key?(:lazy) ? options[:lazy] : false
      request_uri = "#{path_for(:all)}/search?q=#{query}"
      request_uri << '&lazy=false' if !is_lazy
      root = to_underscore(self.name.split('::').last.en.plural)

      ResourceCollection.new(
        options[:client].get(request_uri)[root].collect do |record|
          self.new(
            entity: record,
            lazy: is_lazy,
            tainted: false,
            client: options[:client]
          )
        end,
        type: self,
        client: options[:client]
      )
    end

    def tainted?
      @tainted ? true : false
    end

    # ActiveRecord ActiveModel::Conversion compatibility method
    def to_key
      new? ? [] : [id]
    end

    # ActiveRecord ActiveModel::Conversion compatibility method
    def to_model
      self
    end

    # ActiveRecord ActiveModel::Conversion compatibility method
    def to_param
      new? ? nil : id.to_s
    end

    def <=>(other)
      if id < other.id
        -1
      elsif id > other.id
        1
      elsif id == other.id
        0
      else
        raise Exceptions::InvalidInput
      end
    end

    private

    def self.validate_options(options)
      raise Exceptions::InvalidOptions unless options.is_a?(Hash)
      raise Exceptions::MissingAPIClient unless options[:client]
      raise Exceptions::InvalidAPIClient unless options[:client].is_a?(APIClient)
    end
  end
end
