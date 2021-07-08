# frozen_string_literal: true

require_relative 'middlegem/version'
require_relative 'middlegem/middleware'
require_relative 'middlegem/definition'

# The namespace containing all modules in the middlegem gem.
#
# @author Jacob Lockard
# @since 0.1.0
module Middlegem
  # A subclass of {StandardError} from which all custom errors in the middlegem gem are derived.
  #
  # One potential reason to use this class is for rescuing all custom errors produced by
  # middlegem. For example:
  #   begin
  #     # Do something risky with middlegem here...
  #   rescue Middlegem::Error
  #     # Catch any middlegem-specific error here...
  #   end
  # @see https://ruby-doc.org/core-2.0.0/Exception.html
  class Error < StandardError; end
end
