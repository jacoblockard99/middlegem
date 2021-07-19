# frozen_string_literal: true

class OfficialMiddleware < Middlegem::Middleware
  attr_reader :num

  def initialize(num)
    @num = num

    super()
  end

  def call(input); end
end
