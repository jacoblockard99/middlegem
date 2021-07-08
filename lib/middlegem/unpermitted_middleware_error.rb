# frozen_string_literal: true

module Middlegem
  # An error that is raised when a middleware that is not permitted in a given context is used.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class UnpermittedMiddlewareError < Error; end
end
