# frozen_string_literal: true

module Middlegem
  # A class that represents a chain of middlewares, which, when called, can arbitrarily transform
  # a given input. Most of the functionality middlegem provides lies in this class. Using
  # {Middlegem::Stack} is simple: create a new instance with the desired definition, add
  # whatever middlewares you want to use, and {#call} it.
  #
  # A very basic example of usage is:
  #   class LastNameMiddleware < Middlegem::Middleware
  #     def call(name)
  #       "The Honorable #{name} Lockard"
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
  #   stack.call('Jacob') # => "mail@test.com <The Honorable Jacob Lockard>"
  # Notice that, even though the +EmailStringMiddleware+ was added before the
  # +LastNameMiddleware+, the +EmailStringMiddleware+ was still run first, since it was defined
  # first. That is the main premise of middlegem---rather than providing extensive methods to
  # insert middleware in a specific place along the chain, middlegem simply allows you to define
  # the order explicitly.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class Stack
    # The array of middlewares represented by this {Middlegem::Stack}. You can insert middlewares
    # in any way you like by accessing this attribute directly and using ruby's built-in array
    # methods. If desired, you can even assign a new array to it. All middlewares will be
    # validated before being run. To be run, a middleware must be *valid* as defined by
    # {Middlegem::Middleware.valid?} and it must be *defined* according to the
    # {Middlegem::Definition} instance contained in {#definition}.
    # @return [Array<Object>] the middlewares contained in this stack.
    attr_accessor :middlewares

    # The {Middlegem::Definition} used to determine what middlewares are permitted in this stack
    # and in what order they should be run.
    # @return [Middlegem::Definition} the middleware definition of this stack.
    attr_reader :definition

    # Creates a new instance of {Middlegem::Stack} with the given middleware definition and,
    # optionally, an array of middlewares. Note that middlewares will be validated, not
    # immediately, but before being run.
    # @param definition [Middlegem::Definition] the middleware definition to use to determine
    #   what middleware to permit in this stack and in what order to run them.
    # @param middlwares [Array<Object>] an optional array of initial middlewares in this stack.
    def initialize(definition, middlewares: [])
      unless Definition.valid?(definition)
        raise InvalidDefinitionError, "The middleware definition #{definition} is invalid!"
      end

      @definition = definition
      @middlewares = middlewares
    end

    # Transforms the given input by calling all the middlewares in this stack, as defined by the
    # middleware {#definition}. Note that arguments are already splatted---you should not try to
    # pass a single array of arguments as the only parameter, unless you actually want to
    # transform a single array. Also, as noted in {Middleware#call}, middleware _should_ return
    # an array of arguments, which will be splatted when passed to {Middleware#call}.
    #
    # Midlewares are validated before are run or sorted. If a middleware is encountered that
    # is either invalid or unpermitted, an appropriate error will be raised.
    #
    # @param args [Array<Object>] the array of input arguments.
    # @return the output of the last middleware in the chain.
    # @raise [InvalidMiddlewareError] when one of the middleware in {#middlewares} is not valid,
    #   as defined in {Middlegem::Middleware.valid?}.
    # @raise [UnpermittedMiddlewareError] when one of the middleware in {#middlewares} has not
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
