# frozen_string_literal: true

module Middlegem
  # {Stack} is a class that represents a chain of middlewares, which, when called, can
  # arbitrarily transform a given input. Most of the functionality provided by +middlegem+ lies
  # in this class. Using {Stack} is simple: create a new instance with the desired definition,
  # add whatever middlewares you want to use, and {#call} it.
  #
  # A very basic example of usage is:
  #
  #   class LastNameMiddleware < Middlegem::Middleware
  #     def call(name)
  #       "The Honorable #{name}"
  #     end
  #   end
  #
  #   class EmailStringMiddleware < Middlegem::Middleware
  #     def initialize(email)
  #       @email = email
  #     end
  #
  #     def call(name)
  #       "#{@email} <#{name}>"
  #     end
  #   end
  #
  #   definitions = [
  #     LastNameMiddleware,
  #     EmailStringMiddleware
  #   ]
  #
  #   stack = Middlegem::Stack.new(Middlegem::ArrayDefinition.new(definitions))
  #   stack.middlewares += [EmailStringMiddleware.new('mail@test.com'), LastNameMiddleware.new]
  #
  #   stack.call('Jacob') # => "mail@test.com <The Honorable Jacob>"
  #
  # Notice that, even though the +EmailStringMiddleware+ was added before the
  # +LastNameMiddleware+, the +LastNameMiddleware+ was still run first since it was defined
  # first. That is a core principle of +middlegem+---rather than providing extensive methods to
  # insert middleware in a specific place along the chain, +middlegem+ allows you to define
  # the order explicitly. Also note that there are a variety of ways that you could specify the
  # middleware order by extending {Definition}.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  # @see Middleware
  # @see Definition
  # @see ArrayDefinition
  class Stack
    # An array containing the middlewares represented by this {Stack}. You can insert middlewares
    # in any way you like by accessing this attribute directly and using ruby's built-in array
    # methods. If desired, you can even assign a new array to it. All middlewares will be
    # validated before being run. To be run, a middleware must be *valid* as defined by
    # {Middleware.valid?} and it must be *defined* according to the {Definition} instance
    # in {#definition}.
    # @return [Array<Object>] the middlewares contained in this stack.
    attr_accessor :middlewares

    # The {Definition} used to determine what middlewares are permitted in this stack
    # and in what order they should be run. Note that this attribute may be any object that is a
    # valid definition according to {Definition.valid?}.
    # @return [Definition] the middleware definition of this middleware stack.
    attr_reader :definition

    # Creates a new instance of {Stack} with the given middleware definition and,
    # optionally, an array of middlewares. Note that middlewares will be validated, not
    # immediately, but before being run.
    # @param definition [Definition] the middleware definition to use to determine
    #   what middleware to permit in this stack and in what order to run them. May be any object
    #   that is a valid definition according to {Definition.valid?}.
    # @param middlwares [Array<Object>] an optional array of initial middlewares in this stack.
    def initialize(definition, middlewares: [])
      unless Definition.valid?(definition)
        raise InvalidDefinitionError, "The middleware definition #{definition} is invalid!"
      end

      @definition = definition
      @middlewares = middlewares
    end

    # Transforms the given input by calling all the middlewares in this stack, as defined by the
    # middleware {#definition}. Note that, as mentioned in {Middleware}, middlewares in
    # +middlegem+ transform argument lists. Thus, the arguments are already splatted---there is
    # no need to pass a single array of arguments as the only parameter, unless you actually want
    # to transform just a single array. Also, middleware *must* return an array of arguments,
    # which will be splatted when passed to {Middleware#call}.
    #
    # Midlewares are validated before being run or sorted. If a middleware is encountered that
    # is either invalid or unpermitted, an appropriate error will be raised.
    #
    # @param args [Array<Object>] the array of input arguments.
    # @return [Array<Object>] the output of the last middleware in the chain.
    # @raise [InvalidMiddlewareError] when one of the middlewares in {#middlewares} is not valid,
    #   as defined by {Middleware.valid?}.
    # @raise [UnpermittedMiddlewareError] when one of the middlewares in {#middlewares} has not
    #   been defined, and is thus not permitted, according to the {Definition} instance in
    #   {#definition}.
    def call(*args)
      # Validate the middlewares.
      middlewares.each { |m| ensure_valid!(m) }

      # Sort the middlewares.
      sorted = definition.sort(middlewares)

      # Run each middleware with the output of the previous one, ensuring that each output is
      # valid. For the first middleware, use `args` as the input.
      last_output = args
      sorted.each do |middleware|
        last_output = middleware.call(*last_output)
        ensure_valid_output!(middleware, last_output)
      end

      last_output
    end

    private

    # Ensures that the given middleware is a valid middleware for this middleware stack, raising
    # an appropriate error if not. A middleware is valid if:
    # 1. it is valid according to {Middleware.valid?}, and
    # 2. it is defined according to {#definition}.
    # @param middleware [Object] the middleware to validate.
    # @return [void]
    def ensure_valid!(middleware)
      unless Middleware.valid?(middleware)
        raise InvalidMiddlewareError, "The middleware #{middleware} is not a valid middleware!"
      end

      unless definition.defined?(middleware)
        raise UnpermittedMiddlewareError, "The middleware #{middleware} has not been defined!"
      end
    end

    # Ensures that the given output of the given middleware is valid for all the intents and
    # purposes of this stack. Essentially, the output is valid if it can be passed, splatted, to
    # the next middleware, or returned at the end of the stack. Currently, this method only
    # checks whether the output is an "array" (as defined by the splat operator). If the output
    # is invalid, an appropriate error will be raised.
    # @param middleware [Object] the middleware whose output is being validated. This object is
    #   only used to generate appropriate error messages.
    # @param output [Object] the middleware output to validate.
    # @return [void]
    def ensure_valid_output!(middleware, output)
      unless output == [*output]
        raise InvalidMiddlewareOutputError, <<~ERR
          The middleware #{middleware} outputted #{output}, which is not an array!
        ERR
      end
    end
  end
end
