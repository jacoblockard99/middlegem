# frozen_string_literal: true

require 'spec_helper'
require 'support/open_definition'
require 'support/test_middleware'
require 'support/another_middleware'
require 'support/undefined_middleware'
require 'support/non_array_returning_middleware'

RSpec.describe Middlegem::Stack do
  # run tracks which middleware have run. See TestMiddleware for more details.
  let(:run) { [] }
  let(:definition) { OpenDefinition.new }
  let(:middlewares) do
    [
      TestMiddleware.new(1, run),
      TestMiddleware.new(2, run),
      AnotherMiddleware.new(3, run)
    ]
  end
  let(:invalid_middleware) { Middlegem::Middleware.new }
  let(:stack) { described_class.new(definition, middlewares: middlewares) }

  def call
    stack.call('input')
  end

  def call_safe
    stack.call('input')
  rescue Middlegem::Error
    nil
  end

  describe '#initialize' do
    context 'with an invalid definition' do
      let(:stack) { described_class.new(Middlegem::Definition.new) }

      it 'raises an appropriate error' do
        expect { stack }.to raise_error Middlegem::InvalidDefinitionError
      end
    end

    context 'with initial middlewares' do
      it 'uses them' do
        expect(stack.middlewares.count).to eq 3
      end
    end
  end

  describe '#call' do
    context 'with one invalid middleware' do
      before { stack.middlewares.insert(2, invalid_middleware) }

      it 'raises an appropriate error' do
        expect { call }.to raise_error Middlegem::InvalidMiddlewareError
      end

      it 'runs no middleware' do
        call_safe
        expect(run).to be_empty
      end
    end

    context 'with one non-defined middleware' do
      before { stack.middlewares.insert(2, UndefinedMiddleware.new) }

      it 'raises an appropriate error' do
        expect { call }.to raise_error Middlegem::UnpermittedMiddlewareError
      end

      it 'runs no middleware' do
        call_safe
        expect(run).to be_empty
      end
    end

    context 'with valid middlewares' do
      it 'produces the correct output' do
        expect(call).to eq ['(([input]))']
      end
    end

    context 'with a definition that sorts middlewares' do
      it 'sorts the middlewares' do
        call
        expect(run).to eq [3, 2, 1] # notice the reversed order
      end
    end

    context 'with a middleware that does not return an array' do
      before { stack.middlewares.insert(2, NonArrayReturningMiddleware.new) }

      it 'raises an appropriate error' do
        expect { call }.to raise_error Middlegem::InvalidMiddlewareOutputError
      end

      # NOTE: We'd really prefer it not to run the previous middleware, but the implementation is
      # much simply like this. It may be changed in the future.
      it 'still runs the previous middleware' do
        call_safe
        expect(run).to eq [3]
      end
    end
  end
end
