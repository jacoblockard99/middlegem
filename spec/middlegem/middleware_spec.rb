# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Middlegem::Middleware do
  describe '.valid?' do
    context 'with an object that does not implement `call`' do
      subject { 'a random object' }
      it 'returns false' do
        expect(Middlegem::Middleware.valid?(subject)).to eq false
      end
    end

    context 'with an object that does implement `call`' do
      subject { -> { 'a random string' } }
      it 'returns true' do
        expect(Middlegem::Middleware.valid?(subject)).to eq true
      end
    end

    context 'with a Middleware instance that does not implement `call`' do
      subject { Middlegem::Middleware.new }
      it 'returns false' do
        expect(Middlegem::Middleware.valid?(subject)).to eq false
      end
    end
  end
end
