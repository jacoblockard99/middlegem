# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Middlegem::Middleware do
  describe '.valid?' do
    context 'with an object that does not implement `call`' do
      let(:middleware) { 'a random object' }

      it 'returns false' do
        expect(described_class.valid?(middleware)).to eq false
      end
    end

    context 'with an object that does implement `call`' do
      let(:middleware) { -> { 'a random string' } }

      it 'returns true' do
        expect(described_class.valid?(middleware)).to eq true
      end
    end

    context 'with a Middleware instance that does not implement `call`' do
      let(:middleware) { described_class.new }

      it 'returns false' do
        expect(described_class.valid?(middleware)).to eq false
      end
    end
  end
end
