module Antaeus
  class Resource
    include Comparable

    def self.properties
      @properties ||= {}
    end

    def self.delayed_property(options = {}, &block)
      @properties ||= {}

      @properties[block] = options
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
        
        # Setter methods
        define_method("#{prop}=".to_sym) do |value|
          @entity[prop.to_s] = value
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
        client.get(this_path)[root].collect {|e| self.new(e, lazy ? true : false)},
        self
      )
    end

    def self.where(attribute, value, comparison = '==')
      all(false).where(attribute, value, comparison)
    end

    def id
      @entity['id']
    end

    def initialize(entity = {}, lazy = false)
      @entity = entity
      @lazy   = lazy

      self.class.class_eval do
        gen_property_methods
      end
    end

    def paths
      self.class.paths
    end

    def path_for(kind)
      self.class.path_for(kind)
    end

    def reload
      root = to_underscore(self.class.name.split('::').last)

      client  = APIClient.instance
      @entity = client.get("#{path_for(:all)}/#{id}")[root]
      @lazy   = false
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
