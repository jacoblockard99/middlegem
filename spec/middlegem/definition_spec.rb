# frozen_string_literal: true

require 'spec_helper'
require 'support/test_definition'
require 'support/test_no_sort_definition'
require 'support/test_no_defined_definition'

RSpec.describe Middlegem::Definition do
  describe '.valid?' do
    context 'given an object that responds to `defined?` and `sort`' do
      subject { TestDefinition.new }
      it 'returns true' do
        expect(Middlegem::Definition.valid?(subject)).to eq true
      end
    end

    context 'given an object that responds to `defined?`, but not `sort`' do
      subject { TestNoSortDefinition.new }
      it 'returns false' do
        expect(Middlegem::Definition.valid?(subject)).to eq false
      end
    end

    context 'given an object that responds to `sort`, but not `defined?`' do
      subject { TestNoDefinedDefinition.new }
      it 'returns false' do
        expect(Middlegem::Definition.valid?(subject)).to eq false
      end
    end

    context 'given an invalid Definition instance' do
      subject { Middlegem::Definition.new }
      it 'returns false' do
        expect(Middlegem::Definition.valid?(subject)).to eq false
      end
    end
  end
end
