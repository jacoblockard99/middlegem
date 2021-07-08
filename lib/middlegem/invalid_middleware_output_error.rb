# frozen_string_literal: true

module Middlegem
  # An error that is raised when an middleware object returns an invalid output. This error is
  # most commonly raised when a middleware does not return an array.
  #
  # @author Jacob Lockard
  # @since 0.1.0
  class InvalidMiddlewareOutputError < Error; end
end
