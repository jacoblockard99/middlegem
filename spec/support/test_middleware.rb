# frozen_string_literal: true

class TestMiddleware
  attr_accessor :num, :run, :priority

  def initialize(num, run, priority: 1)
    @num = num
    @run = run
    @priority = priority
  end

  def call(input)
    @run << @num
    ["(#{input})"]
  end
end
