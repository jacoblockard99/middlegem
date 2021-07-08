# frozen_string_literal: true

module Middlegem
  # An implementation of {Definition} that allows middlewares to be defined and ordered by their
  # classes in an array. For example, it can be used like this:
  #   definition = Middlegem::ArrayDefinition.new([
  #     MiddlewareOne,   # appends '1'
  #     MiddlewareTwo,   # appends '2'
  #     MiddlewareThree, # appends '3'
  #     MiddlewareFinal  # appends '.'
  #   ])
  #
  #   stack = Middlegem::Stack.new(definition, middlewares: [
  #     MiddlewareThree.new,
  #     MiddlewareFinal.new,
  #     MiddlewareOne.new,
  #     MiddlewareTwo.new
  #   ])
  #
  #   stack.call('hello') # => 'hello123.'
  # Notice that the middleware are run in the order specified by the definitions array.
  #
  # If two or more middlewares are encountered with the same class, they will be left in the same
  # order they were added. This behavior can be customized by passing a tie resolver to the
  # constructor. For example:
  #   middlewares = [
  #     MiddlewareOne,   # appends '1'
  #     MiddlewareTwo,   # appends '2'
  #     MiddlewareThree, # appends '3'
  #     MiddlewareFinal  # appends a given character
  #   ]
  #
  #   tie_resolver = proc do |*ties|
  #     # Assuming that MiddlewareFinal has a #character method.
  #     ties.sort_by(&:character)
  #   end
  #
  #   definition = Middlegem::ArrayDefinition.new(middlewares, resolver: tie_resolver)
  #
  #   stack = Middlegem::Stack.new(definition, middlewares: [
  #     MiddlewareTwo.new,
  #     MiddlewareOne.new,
  #     MiddlewareFinal.new('a'),
  #     MiddlewareThree.new,
  #     MiddlewareFinal.new('c'),
  #     MiddlewareFinal.new('b')
  #   ])
  #
  #   stack.call('hello') # => 'hello123abc'
  # Notice how the MiddlewareFinal middlewares are sorted by the resolver since they have the
  # same class. You should be careful with this however! Remember that the resolver will be run
  # for _any_ ties. You really should include this sort of check:
  #   tie_resolver = proc do |*ties|
  #     case ties
  #     when MiddlewareFinal
  #       ties.sort_by(&:character)
  #     when ...
  #       # Etc.
  #     else
  #       ties
  #     end
  #   end
  # In general, except for very specific use cases, if you have to use a resolver, you should
  # probably just build your own {Definition} class. The {ArrayDefinition} class is meant almost
  # exclusively for defining middlewares according to their classes.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class ArrayDefinition < Definition
    # The ordered array of classes defined by this {ArrayDefinition}. Middlewares will only be
    # permitted if their class is in this array, and middlewares will be run in the order
    # specified in this array.
    # @return [Array<Class>] the ordered array of defined classes.
    attr_accessor :defined_classes

    # The callable object to use to break ties when sorting middlewares. When multiple
    # middlewares of the same type are encountered, {#sort} will call this object with the
    # array of tied middlewares. The resolver should sort and return the array as appropriate.
    # @return [#call] the middleware tie resolver.
    attr_reader :resolver

    # Creates a new instance of {ArrayDefinition} with the given array of defined classes and,
    # optionally, a callable obejct to be used to resolve sorting ties.
    # @param defined_classes [Object<Class>] an ordered array of classes to be defined by this
    #   {ArrayDefinition} (see {#defined_classes}).
    # @param resolver [#call, nil] a callable object to use when middlewares of the same class
    #   are encountered (see {#resolver}). If a +nil+ resolver is passed (the default), the
    #   default resolver will be used, which keeps tied middlewares in the order they are passed
    #   to {#sort}.
    def initialize(defined_classes, resolver: nil)
      resolver = ->(*ties) { ties } if resolver.nil?

      @defined_classes = defined_classes
      @resolver = resolver
      super()
    end

    # Determines whether the given middleware is defined according to this {ArrayDefinition} by
    # checking whether its class is contained in the list of defined classes
    # ({#defined_classes}).
    # @param middleware [Object] the middleware to check.
    # @return [bool] whether the middleware is defined.
    def defined?(middleware)
      defined_classes.include?(middleware.class)
    end

    # Sorts the given array of middlewares according to this {ArrayDefinition}. Middlewares are
    # sorted according to the order in which their classes are specified in {#defined_classes}.
    # If multiple middlewares of the same type are encountered, they will be resolved with the
    # {#resolver}.
    def sort(middlewares)
      defined_classes.map { |c| resolver.call(*matches(middlewares, c)) }.flatten
    end

    private

    # Gets all the middlewares in the given array whose class is the given class.
    # @param middlewares [Array<Object>] the middlewares to search.
    # @param klass [Class] the class to search for.
    # @return [Array<Object>] the matched middlewares.
    def matches(middlewares, klass)
      middlewares.select { |m| m.instance_of?(klass) }
    end
  end
end
