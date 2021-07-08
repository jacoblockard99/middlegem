# frozen_string_literal: true

module Middlegem
  # {Definition} is an abstract class whose implementations are capable of defining what
  # middlewares are permitted in a given context and in what order they should be executed. Note
  # that this concept of "middleware definitions" is a major difference from other middleware
  # solutions, where middlewares are simply inserted into a stack. In +middlegem+, a
  # {Definition} determines what order the middleware in a {Stack} should be called. This greatly
  # decreases the likelihood of "middleware conflicts", where one middleware expects another to
  # have already run. The downside, of course, is the verbosity---all middleware must be defined.
  #
  # It should be noted, however, that the concept of a "middleware definition" is completely
  # flexible. If you would prefer to simply insert middlewares into a stack without defining
  # them, you can create a {Definition} implentation whose {#sort} method just returns the
  # unsorted middlewares. And if you want to allow any middlewares to be inserted, simply return
  # +true+ from the {#defined?} method. On the other hand, there is a lot of flexibility in how
  # you determine the middleware order: define a DSL, let middleware have dependencies, define
  # middleware "groups", allow middleware "priorities"---the possibilities are endless!
  #
  # Currently, the only default implementation is {ArrayDefinition}, which executes
  # middleware based on an ordered list of middleware classes.
  #
  # Finally, you might notice that {Definition} contains no actual instance method
  # implementations. In other words, for all intents and pruposes, it is empty! This is
  # intentional. A middleware definition is *any* object that implements both a {#defined?} and a
  # {#sort} method (see {.valid?}). You may extend this class, however, to explicitly mark your
  # middleware definition classes as middleware definitions.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  # @abstract
  class Definition
    # Determines whether the given object is a valid middleware definition. Currently, any object
    # that implements a +defined?+ method and a +sort+ method is valid.
    #
    # @param definition [Object] the middleware definition to check.
    # @return [bool] whether the given object is a valid middleware definition.
    def self.valid?(definition)
      definition.respond_to?(:defined?) && definition.respond_to?(:sort)
    end

    # @!method defined?(middleware)
    #   Should determine whether the given middleware is defined according to this
    #   {Definition}. Feel free to determine this however you like! This method will
    #   be used to validate middlewares added to a {Stack}.
    #   @param middleware [Object] the middleware object to check.
    #   @return [bool] whether the given middleware object is defined.

    # @!method sort(middlewares)
    #   Should sort the given array of middlewares according to this {Definition}. In a {Stack},
    #   middlewares will be called in the order returned.
    #   @param middlewares [Array<Object>] the middlewares to sort.
    #   @return [Array<Object>] the sorted middlewares.
  end
end
