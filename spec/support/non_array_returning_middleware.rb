# frozen_string_literal: true

class NonArrayReturningMiddleware
  def call(_input)
    'a single string'
  end
end
