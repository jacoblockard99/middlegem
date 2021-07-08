# frozen_string_literal: true

class TestMiddleware
  def initialize(num, run)
    @num = num
    @run = run
  end

  def call(input)
    @run << @num
    ["(#{input})"]
  end
end
