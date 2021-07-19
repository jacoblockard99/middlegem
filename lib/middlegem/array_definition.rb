# frozen_string_literal: true

module Middlegem
  # {ArrayDefinition} is an implementation of {Definition} that allows middlewares to be
  # explicitly defined and ordered by class in an array. A basic example of usage is:
  #
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
  #   stack.call('hello') # => ['hello123.']
  #
  # Notice that the middlewares are called in the order they are specified in the definition
  # array.
  #
  # If two or more middlewares are encountered that have the same class, they will be left in the
  # order they were added. This behavior can be overriden by setting a tie resolver. The
  # following code, for example, raises an error when  multiple +MiddlewareFinal+ middlewares
  # are encountered:
  #
  #   middlewares = [
  #     MiddlewareOne,
  #     MiddlewareTwo,
  #     MiddlewareThree,
  #     MiddlewareFinal
  #   ]
  #
  #   tie_resolver = proc do |ties|
  #     raise "Can't run multiple MiddlewareFinals!" if ties.first.is_a? MiddlewareFinal
  #     ties
  #   end
  #
  #   definition = Middlegem::ArrayDefinition.new(middlewares, resolver: tie_resolver)
  #
  #   stack = Middlegem::Stack.new(definition, middlewares: [
  #     MiddlewareTwo.new,
  #     MiddlewareOne.new,
  #     MiddlewareFinal.new,
  #     MiddlewareThree.new,
  #     MiddlewareFinal.new
  #   ])
  #
  #   stack.call('hello') # => RuntimeError (Can't run multiple MiddlewareFinals!)
  #
  # When the two +MiddlewareFinal+ instances are encountered, the tie resolver is run, which
  # raises the error.
  #
  # Of course, this is only scratching the surface of what is possible with
  # a custom tie resolver. You might, for example, simply skip other instances of
  # +MiddlewareFinal+, rather than raising an error. A word of caution is in order, however!
  # It is not recommended to try anything too complicated with the tie resolver because it is run
  # for <em>all ties whatsoever</em>. That means that, while you could technically try to sort
  # middlewares with the same class based on some other factor---there is even an example
  # in +spec/middlegem/array_definition_spec.rb+---it potentially results in long +if/else+ or
  # +case/when+ constructions because each type must be dealt with separately. Use at your own risk!
  #
  # In general, if you need to use a tie resolver for anything but the most basic of tasks, you
  # should probably just create your own {Definition} implementation with the required
  # functionality. {ArrayDefinition} is intended primarily for defining middlewares according to
  # their classes and nothing more.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  # @see Definition
  class ArrayDefinition < Definition
    # An array of the middleware classes defined by this {ArrayDefinition}. Middlewares will only
    # be permitted if their class is in this array will be run in the order specified here.
    # @return [Array<Class>] the array of defined classes.
    attr_accessor :defined_classes

    # The callable object to use to break ties when sorting middlewares. When multiple
    # middlewares of the same type are encountered, this object will be called with an
    # array of all tied middlewares. The resolver should sort and return the array as
    # appropriate.
    # @return [#call] the middleware tie resolver.
    attr_reader :resolver

    # Creates a new instance of {ArrayDefinition} with the given array of defined classes and,
    # optionally, a custom tie resolver.
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
    # (i.e. {#defined_classes}).
    # @param middleware [Object] the middleware to check.
    # @return [bool] whether the middleware is defined.
    def defined?(middleware)
      defined_classes.any? { |c| matches_class?(middleware, c) }
    end

    # Sorts the given array of middlewares according to this {ArrayDefinition}. Middlewares are
    # sorted according to the order in which their classes are specified in {#defined_classes}.
    # If multiple middlewares of the same type are encountered, they will be resolved with the
    # {#resolver}.
    # @param middlewares [Array<Object>] the middlewares to sort.
    # @return [Array<Object>] the sorted middlewares.
    def sort(middlewares)
      defined_classes.map { |c| resolver.call(matches(middlewares, c)) }.flatten
    end

    protected

    # Should determine whether the given middleware's evaluated class is equal to the given one.
    # The default implementation naturally just uses +instance_of?+, but you are free to
    # override this method for other situations. You may want is use +is_a?+ instead, for
    # example, or perhaps a middleware's "class" is based on some other criterion.
    # @param middleware [Object] the middleware to check.
    # @param klass [Class] the class against which to check the middleware.
    # @return [Boolean] whether the given middleware has the given class.
    # @since 0.2.0
    def matches_class?(middleware, klass)
      middleware.instance_of? klass
    end

    private

    # Gets all the middlewares in the given array whose class is the given class.
    # @param middlewares [Array<Object>] the array of middlewares to search.
    # @param klass [Class] the class to search for.
    # @return [Array<Object>] the matched middlewares.
    def matches(middlewares, klass)
      middlewares.select { |m| matches_class?(m, klass) }
    end
  end
end
