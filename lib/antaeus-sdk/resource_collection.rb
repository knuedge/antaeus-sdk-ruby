module Antaeus
  # The ResourceCollection class
  # Should not allow or use mixed types
  class ResourceCollection
    include Enumerable
    include Comparable

    # @return [Class] this is a collection of this {Resource} subclass
    attr_reader :type

    def initialize(list, type = nil)
      fail 'Exceptions::InvalidCollection' if list.empty? and type.nil?
      @list = list
      if type.nil?
        @type = list.first.class
      else
        @type = type
      end
    end

    def each(&block)
      @list.each(&block)
    end

    # Does the collection contain anything?
    # @return [Boolean]
    def empty?
      @list.empty?
    end

    def first(n = nil)
      if n
        self.class.new(@list.first(n), @type)
      else
        @list.first
      end
    end

    def last(n = nil)
      if n
        self.class.new(@list.last(n), @type)
      else
        @list.last
      end
    end

    # Merge two collections
    # @return [ResourceCollection]
    def merge(other)
      if other.is_a?(self.class)
        new_list = @list.dup
        self + (other - self)
      else
        fail "Exceptions::InvalidInput"
      end
    end

    # Makes #model compatible with the server-side
    def model
      type
    end

    # Hacked together #or() method in the same spirit as #where().
    # This method can be chained for multiple / more specific queries.
    #
    # @param attribute [Symbol] the attribute to query
    # @param value [Object] the value to compare against
    # @param comparison_method [String,Symbol] the method to use for comparison
    #   - allowed options are "'==', '!=', '>', '>=', '<', '<=', and 'match'"
    # @raise [Exceptions::InvalidWhereQuery] if not the right kind of comparison
    # @return [ResourceCollection]
    def or(attribute, value, comparison = '==')
      if empty?
        @type.where(attribute, value, comparison)
      else
        merge first.class.where(attribute, value, compariso)
      end
    end

    # Returns the number of Resource instances in the collection
    # @return [Fixnum]
    def size
      @list.size
    end

    # Allow complex sorting like an Array
    # @return [ResourceCollection] sorted collection
    def sort(&block)
      self.class.new(super(&block), @type)
    end

    # Horribly inefficient way to allow querying Resources by their attributes.
    # This method can be chained for multiple / more specific queries.
    #
    # @param attribute [Symbol] the attribute to query
    # @param value [Object] the value to compare against
    # @param comparison_method [String,Symbol] the method to use for comparison
    #   - allowed options are "'==', '!=', '>', '>=', '<', '<=', and 'match'"
    # @raise [Exceptions::InvalidWhereQuery] if not the right kind of comparison
    # @return [ResourceCollection]
    def where(attribute, value, comparison = '==')
      valid_comparisons = [:'==', :'!=', :>, :'>=', :<, :'<=', :match]
      unless valid_comparisons.include?(comparison.to_sym)
        fail 'Exceptions::InvalidWhereQuery'
      end
      self.class.new(
        @list.collect do |item|
          if item.send(attribute).nil?
            nil
          else
            item if item.send(attribute).send(comparison.to_sym, value)
          end
        end.compact,
        @type
      )
    end

    alias_method :and, :where

    # Return the collection item at the specified index
    # @return [Resource,ResourceCollection] the item at the requested index
    def [](index)
      if index.is_a?(Range)
        self.class.new(@list[index])
      else
        @list[index]
      end
    end

    # Return a collection after subtracting from the original
    # @return [ResourceCollection]
    def -(other)
      new_list = @list.dup
      if other.respond_to?(:to_a)
        other.to_a.each do |item|
          new_list.delete_if { |res| res.id == item.id }
        end
      elsif other.is_a?(Resource)
        new_list.delete_if { |res| res.id == other.id }
      else
        fail "Exceptions::InvalidInput"
      end
      self.class.new(new_list, @type)
    end

    # Return a collection after adding to the original
    #   Warning: this may cause duplicates or mixed type joins! For safety,
    #   use #merge
    # @return [ResourceCollection]
    def +(other)
      if other.is_a?(self.class)
        self.class.new(@list + other.to_a, @type)
      elsif other.is_a?(@type)
        self.class.new(@list + [other], @type)
      else
        fail "Exceptions::InvalidInput"
      end
    end

    def <<(other)
      if other.class == @type
        @list << other
      else
        fail "Exceptions::InvalidInput"
      end
    end

    def <=>(other)
      collect(&:id).sort <=> other.collect(&:id).sort
    end

    # Allow comparison of collection
    # @return [Boolean] do the collections contain the same resource ids?
    def ==(other)
      if other.is_a? self.class
        collect(&:id).sort == other.collect(&:id).sort
      else
        false
      end
    end
  end
end
