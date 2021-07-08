# frozen_string_literal: true

module Middlegem
  # An abstract representation of a single "middleware". A middleware is a transforming function
  # that accepts arbitrary input and produces arbitrary output. Note that this class is not
  # strictly necessary---any object that responds to the +call+ method is a valid middleware! You
  # may make your middleware classes explicit, however, by extending this class.
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
