# frozen_string_literal: true

module Middlegem
  # An error that is raised when an object that is not a valid middleware is used like one.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class InvalidMiddlewareError < Error; end
end
