# frozen_string_literal: true

class BlockedMiddleware
  def call(*)
    raise 'This should never be called!'
  end
end
