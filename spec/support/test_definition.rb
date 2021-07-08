# frozen_string_literal: true

# Note the lack of `< Middlegem::Defintion`!
class TestDefinition
  def defined?(definition)
    definition
  end

  def sort(middlewares)
    middlewares.reverse
  end
end
