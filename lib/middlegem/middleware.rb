# frozen_string_literal: true

module Middlegem
  # {Middleware} is an abstract representation of a single "middleware". A middleware is a
  # transforming function that accepts arbitrary input and produces arbitrary output.
  # Middlewares can be chained with {Stack} to produce powerful, flexible data-transforming
  # layers.
  #
  # One important concept to note is that middlewares in +middlegem+ are "one-way". In other
  # words, they cannot transform both a "request" and a "response". For this functionality,
  # please see other gems such as {https://github.com/Ibsciss/ruby-middleware ruby-middleware} or
  # (for web requests) {https://github.com/rack/rack rack}.
  #
  # Middlewares in +middlegem+ are also slightly different in exactly what they operate upon.
  # Whereas the middlewares in +ruby-middleware+ simply transform a single +env+
  # variable, +middlegem+ middlewares transform an entire argument list. This may or may not be
  # desirable, as it requires all middlewares to return an array, but it highlights the primary
  # use case for +middlegem+. While it can be used for a variety of purposes, +middlegem+ was
  # specifically designed for filtering and changing arguments passed to a method.
  #
  # Finally, you might notice that {Middleware} contains no actual instance method
  # implementations. In other words, for all intents and pruposes, it is empty! This is
  # intentional. A middleware is *any* object that implements a {#call} method (you read that
  # right---a proc is a valid middleware!). You may extend this class, however, to explicitly
  # mark your middleware classes as middlewares.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  # @abstract
  # @see Middlegem::Stack
  class Middleware
    # Determines whether the given object is a valid middleware. Currently, any object that
    # responds to the +call+ method is valid.
    #
    # @param middleware [Object] the middleware to check.
    # @return [bool] whether the given object is a valid middleware.
    def self.valid?(middleware)
      middleware.respond_to?(:call)
    end

    # @!method call(*args)
    #   The method called to actually execute the middleware. It is passed the output of the
    #   previous middleware in the chain and should return the appropriately transformed output
    #   to be passed to the next middleware. Note that the splat operator is intentional! This
    #   method will be called with actual arguments, not an array. This means that you can
    #   simply define the arguments you expect directly in the method signature, rather than
    #   accepting a splatted array and accessing its elements. For example, the following is
    #   possible:
    #     class MyMiddleware
    #       def call(first, last, email)
    #         return "#{email} <#{first} #{last}>"
    #       end
    #     end
    #   @param args [Array<Object>] the input to be transformed, usually the output of the
    #     previous middleware in a middleware chain.
    #   @return [Object, Array<Object>] the transformed output. Note that if an array is
    #     returned, it will be splatted before being passed to the next middleware.
    #   @note This method must be implemented by all middleware!
  end
end
