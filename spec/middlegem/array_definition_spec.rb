# frozen_string_literal: true

require 'spec_helper'
require 'support/test_middleware'
require 'support/another_middleware'
require 'support/blocked_middleware'

RSpec.describe Middlegem::ArrayDefinition do
  let(:definition_list) do
    [
      TestMiddleware,
      AnotherMiddleware
    ]
  end
  let(:resolver) { ->(*ties) { ties.sort_by(&:priority) } }
  let(:definition) { described_class.new(definition_list, resolver: resolver) }

  describe '#defined?' do
    context 'when given an object whose class is in the definition list' do
      it 'returns true' do
        expect(definition.defined?(TestMiddleware.new(1, []))).to eq true
      end
    end

    context 'when given an object whose class is not in the definition list' do
      it 'returns false' do
        expect(definition.defined?(BlockedMiddleware.new)).to eq false
      end
    end
  end

  describe '#sort' do
    let(:sorted) { definition.sort(middlewares) }

    context 'with an array of middlewares of unique classes' do
      let(:middlewares) do
        [
          AnotherMiddleware.new(1, []),
          TestMiddleware.new(2, [])
        ]
      end

      it 'sorts them correctly' do
        expect(sorted.map(&:class)).to eq [TestMiddleware, AnotherMiddleware]
      end
    end

    context 'with identical middleware classes without a resolver' do
      let(:resolver) { nil }
      let(:middlewares) do
        [
          AnotherMiddleware.new(5, []),
          AnotherMiddleware.new(3, []),
          TestMiddleware.new(4, []),
          AnotherMiddleware.new(2, []),
          TestMiddleware.new(1, [])
        ]
      end

      it 'keeps them in the same order' do
        expect(sorted.map(&:num)).to eq [4, 1, 5, 3, 2]
      end
    end

    context 'with identical middleware classes with a resolver' do
      let(:middlewares) do
        [
          AnotherMiddleware.new(5, [], priority: 2),
          AnotherMiddleware.new(3, [], priority: 3),
          TestMiddleware.new(4, [], priority: 2),
          AnotherMiddleware.new(2, [], priority: 1),
          TestMiddleware.new(1, [], priority: 1)
        ]
      end

      it 'correctly utilizes it' do
        expect(sorted.map(&:num)).to eq [1, 4, 2, 5, 3]
      end
    end
  end
end
