# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Priming::Helpers::Constants do
  describe 'PRIME_BOOST' do
    it 'is a positive float' do
      expect(described_class::PRIME_BOOST).to be > 0.0
      expect(described_class::PRIME_BOOST).to be <= 1.0
    end
  end

  describe 'PRIME_DECAY' do
    it 'is a positive float less than boost' do
      expect(described_class::PRIME_DECAY).to be > 0.0
      expect(described_class::PRIME_DECAY).to be < described_class::PRIME_BOOST
    end
  end

  describe 'SPREAD_FACTOR' do
    it 'is between 0 and 1' do
      expect(described_class::SPREAD_FACTOR).to be_between(0.0, 1.0).exclusive
    end
  end

  describe 'MAX_SPREAD_HOPS' do
    it 'is a positive integer' do
      expect(described_class::MAX_SPREAD_HOPS).to be_a(Integer)
      expect(described_class::MAX_SPREAD_HOPS).to be > 0
    end
  end

  describe 'PRIME_THRESHOLD' do
    it 'is a small positive float' do
      expect(described_class::PRIME_THRESHOLD).to be > 0.0
      expect(described_class::PRIME_THRESHOLD).to be < described_class::PRIME_BOOST
    end
  end

  describe 'association constants' do
    it 'has floor less than ceiling' do
      expect(described_class::ASSOCIATION_FLOOR).to be < described_class::ASSOCIATION_CEILING
    end

    it 'has default between floor and ceiling' do
      expect(described_class::DEFAULT_ASSOCIATION_STRENGTH).to be_between(
        described_class::ASSOCIATION_FLOOR, described_class::ASSOCIATION_CEILING
      )
    end
  end
end
