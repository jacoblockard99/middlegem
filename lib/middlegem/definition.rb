# frozen_string_literal: true

module Middlegem
  # An abstract class that defines what middleware are permitted in a given context and in what
  # order they should run. Note that this concept of "middleware definitions" is a major
  # difference from other ruby middleware solutions, where middleware are simply inserted into a
  # stack. In middlegem, a {Middlegem::Definition} determines what order the middleware in a
  # {Middlegem::Stack} should be called. This greatly decreases the likelihood of "middleware
  # conflicts", where one middleware expects another to have already run. The downside, of
  # course, is the verbosity---all middleware must be defined.
  #
  # It should be noted, however, that this class is completely flexible. If you don't really care
  # about the order in which middlewares are run, you can simply return an unsorted array in
  # {#sort}. And if you don't care what middlewares are used in your middleware stack, you can
  # simply return +true+ in {#defined?}. On the other hand, there is a lot of flexibility in how
  # you determine the middleware order: define a DSL, let middleware have dependencies, define
  # "middleware groups"---the possibilities are endless!
  #
  # Currently, the only default implementation is {Middlegem::ArrayDefinition}, which executes
  # middleware based on an ordered list of middleware classes.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  # @abstract
  class Definition
    # Determines whether the given object is a valid middleware definition. Currently, any obejct
    # that respond to the +defined?+ method and the +sort+ method is valid.
    #
    # @param definition [Object] the middleware definition to check.
    # @return [bool] whether the given object is a valid middleware definition.
    def self.valid?(definition)
      definition.respond_to?(:defined?) && definition.respond_to?(:sort)
    end

    # @!method defined?(middleware)
    #   Determines whether the given middleware is defined according to this
    #   {Middlegem::Definition}. Feel free to determine this however you like! This method will
    #   be used to validate middlewares added to a {Middlegem::Stack}.
    #   @param middleware [Object] the middleware object to check.
    #   @return [bool] whether the given middleware object is defined.

    # @!method sort(middlewares)
    #   Sorts the given array of middlewares according to this {Middlegem::Definition}. The
    #   middlewares will be called in the order returned.
    #   @param middlewares [Array<Object>] the middlewares to sort.
    #   @return [Array<Object>] the sorted middlewares.
  end
end
