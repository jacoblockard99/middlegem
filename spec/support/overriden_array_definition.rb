# frozen_string_literal: true

class OverridenArrayDefinition < Middlegem::ArrayDefinition
  protected

  def matches_class?(middleware, klass)
    middleware.is_a? klass
  end
end
