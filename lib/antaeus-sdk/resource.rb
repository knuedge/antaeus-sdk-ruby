module Antaeus
  class Resource
    include Comparable

    def self.properties
      @properties ||= {}
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
      fail 'Exception::InvalidProperty' if invalid_prop_names.include?(name.to_sym)
      @properties[name.to_sym] = options
    end

    def self.path(kind, uri)
      @paths ||= {}
      @paths[kind.to_sym] = uri
    end

    def self.path_for(kind)
      @paths ||= {}
      @paths[kind.to_sym]
    end

    def self.gen_property_methods
      properties.each do |prop,opts|
        # Getter methods
        define_method(prop) do
          @entity[prop.to_s]
        end
        
        # Setter methods
        define_method("#{prop}=".to_sym) do |value|
          @entity[prop.to_s] = value
        end
      end
    end

    def self.all
      # TODO use a specialized  API REST client to get things
      # TODO add validation checks for the required pieces
      fail "Exceptions::MissingPath" unless path_for(:all)

      root = to_underscore(self.name.split('::').last.en.plural)

      client = APIClient.instance
      ResourceCollection.new(
        client.get(path_for(:all))[root].collect {|e| self.new(e)},
        self
      )
    end

    def id
      @entity['id']
    end

    def initialize(entity = {})
      @entity = entity
      self.class.class_eval do
        gen_property_methods
      end
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
