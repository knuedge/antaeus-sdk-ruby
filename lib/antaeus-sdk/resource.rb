module Antaeus
  class Resource
    include Comparable

    def self.properties
      @properties ||= {}
    end

    # Delayed properties are evaluated when an instance is created
    # WARNING: Sanity checking of the end-result isn't possible, so use with care
    def self.delayed_property(options = {}, &block)
      @properties ||= {}

      @properties[block] = options
    end

    # Can this type of resource be changed client-side?
    def self.immutable(status)
      unless status.is_a?(TrueClass) || status.is_a?(FalseClass)
        fail 'Exceptions::InvalidImmutabilityStatus'
      end
      @immutable = status
    end

    # Check if a resource class is immutable
    def self.immutable?
      @immutable ||= false
    end

    # Define a property for a model
    # TODO add validations on options and names
    def self.property(name, options = {})
      @properties ||= {}

      invalid_prop_names = [
        :>, :<, :'=', :class, :def,
        :%, :'!', :/, :'.', :'?', :*, :'{}',
        :'[]'
      ]
      
      fail(Exception::InvalidProperty) if invalid_prop_names.include?(name.to_sym)
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
      properties.each do |prop,opts|
        if prop.is_a?(Proc)
          prop = prop.call.to_s.to_sym
        end

        # Getter methods
        define_method(prop) do
          if @lazy && !@entity.key?(prop.to_s)
            reload
          end
          @entity[prop.to_s]
        end

        # Setter methods (don't make one for obviously read-only properties)
        unless prop.match /\?$/ || opts[:read_only]
          define_method("#{prop}=".to_sym) do |value|
            if immutable?
              fail "Exceptions::ImmutableModification"
            else
              @entity[prop.to_s] = value
              @tainted = true
            end
          end
        end
      end
    end

    def self.all(lazy = true)
      # TODO use a specialized  API REST client to get things
      # TODO add validation checks for the required pieces
      fail(Exceptions::MissingPath) unless path_for(:all)

      root = to_underscore(self.name.split('::').last.en.plural)
      this_path = lazy ? path_for(:all) : "#{path_for(:all)}?lazy=false"

      client = APIClient.instance
      ResourceCollection.new(
        client.get(this_path)[root].collect do |entities|
          self.new(
            entities,
            lazy: (lazy ? true : false),
            tainted: false
          )
        end,
        self
      )
    end

    def self.get(id)
      fail(Exceptions::MissingPath) unless path_for(:all)

      root = to_underscore(self.name.split('::').last)
      client = APIClient.instance
      self.new(
        client.get("#{path_for(:all)}/#{id}")[root],
        lazy: false,
        tainted: false
      )
    end

    def self.where(attribute, value, comparison = '==')
      all(false).where(attribute, value, comparison)
    end

    def destroy
      fail "Exceptions::ImmutableInstance" if immutable?
      unless new?
        client = APIClient.instance
        client.delete("#{path_for(:all)}/#{id}")
        @lazy = false
        @tainted = true
        @entity.delete('id')
      end
      true
    end

    def fresh?
      !tainted?
    end

    def id
      @entity['id']
    end

    def immutable?
      self.class.immutable?
    end

    def initialize(entity = {}, options = {})
      @entity  = entity
      fail 'Exceptions::InvalidOptions' unless options.is_a?(Hash)
      # Allows lazy-loading if we're told this is a lazy instance
      #  This means only the minimal attributes were fetched.
      #  This shouldn't be set by end-users.
      @lazy    = options.key?(:lazy) ? options[:lazy] : false
      # This allows local, user-created instances to be differentiated from fetched
      # instances from the backend API. This shouldn't be set by end-users.
      @tainted = options.key?(:tainted) ? options[:tainted] : true

      if immutable? && @tainted
        fail "Exceptions::ImmutableInstance"
      end

      # The 'id' field should not be set manually
      if @entity.key?('id')
        fail "Exceptions::NewInstanceWithID" unless !@tainted
      end

      self.class.class_eval do
        gen_property_methods
      end
    end

    def new?
      !@entity.key?('id')
    end

    def paths
      self.class.paths
    end

    def path_for(kind)
      self.class.path_for(kind)
    end

    def reload
      root = to_underscore(self.class.name.split('::').last)

      if new?
        # Can't reload a new resource
        false
      else
        client   = APIClient.instance
        @entity  = client.get("#{path_for(:all)}/#{id}")[root]
        @lazy    = false
        @tainted = false
        true
      end
    end

    def save
      root = to_underscore(self.class.name.split('::').last)

      client   = APIClient.instance
      if new?
        @entity  = client.post("#{path_for(:all)}", @entity)[root]
        @lazy    = false
      else
        client.put("#{path_for(:all)}/#{id}", @entity)
      end
      @tainted = false
      true
    end

    def self.search(query, options = {})
      is_lazy = options.key?(:lazy) ? options[:lazy] : false
      request_uri = "#{path_for(:all)}/search?q=#{query.to_s}"
      request_uri << '&lazy=false' if !is_lazy
      root = to_underscore(self.name.split('::').last.en.plural)

      client = APIClient.instance
      ResourceCollection.new(
        client.get(request_uri)[root].collect do |entities|
          self.new(
            entities,
            lazy: is_lazy,
            tainted: false
          )
        end,
        self
      )
    end

    def tainted?
      @tainted ? true : false
    end

    def <=>(other)
      if id < other.id
        -1
      elsif id > other.id
        1
      elsif id == other.id
        0
      else
        fail 'Exceptions::InvalidComparison'
      end
    end
  end
end
