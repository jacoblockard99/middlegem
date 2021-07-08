# frozen_string_literal: true

require 'spec_helper'
require 'support/test_definition'
require 'support/test_no_sort_definition'
require 'support/test_no_defined_definition'

RSpec.describe Middlegem::Definition do
  describe '.valid?' do
    context 'when given an object that responds to `defined?` and `sort`' do
      let(:definition) { TestDefinition.new }

      it 'returns true' do
        expect(described_class.valid?(definition)).to eq true
      end
    end

    context 'when given an object that responds to `defined?`, but not `sort`' do
      let(:definition) { TestNoSortDefinition.new }

      it 'returns false' do
        expect(described_class.valid?(definition)).to eq false
      end
    end

    context 'when given an object that responds to `sort`, but not `defined?`' do
      let(:definition) { TestNoDefinedDefinition.new }

      it 'returns false' do
        expect(described_class.valid?(definition)).to eq false
      end
    end

    context 'when given an invalid Definition instance' do
      let(:definition) { described_class.new }

      it 'returns false' do
        expect(described_class.valid?(definition)).to eq false
      end
    end
  end
end
