# frozen_string_literal: true

class OpenDefinition
  def defined?(middleware)
    !middleware.is_a?(UndefinedMiddleware)
  end

  def sort(middlewares)
    middlewares.reverse
  end
end
