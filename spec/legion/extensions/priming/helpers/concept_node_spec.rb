# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Priming::Helpers::ConceptNode do
  subject(:node) { described_class.new(name: :dog, domain: :animals) }

  let(:constants) { Legion::Extensions::Priming::Helpers::Constants }

  describe '#initialize' do
    it 'stores name and domain' do
      expect(node.name).to eq(:dog)
      expect(node.domain).to eq(:animals)
    end

    it 'starts with zero activation' do
      expect(node.activation).to eq(0.0)
    end

    it 'starts with no prime source' do
      expect(node.prime_source).to be_nil
    end

    it 'starts with empty associations' do
      expect(node.associations).to eq({})
    end

    it 'defaults domain to general' do
      general = described_class.new(name: :thing)
      expect(general.domain).to eq(:general)
    end
  end

  describe '#primed?' do
    it 'is false when activation is zero' do
      expect(node.primed?).to be false
    end

    it 'is true when activation exceeds threshold' do
      node.prime
      expect(node.primed?).to be true
    end
  end

  describe '#associate' do
    it 'adds an association' do
      node.associate(:cat)
      expect(node.associations).to have_key(:cat)
    end

    it 'uses default strength' do
      node.associate(:cat)
      expect(node.association_strength(:cat)).to eq(constants::DEFAULT_ASSOCIATION_STRENGTH)
    end

    it 'accepts custom strength' do
      node.associate(:cat, strength: 0.8)
      expect(node.association_strength(:cat)).to eq(0.8)
    end

    it 'clamps strength within bounds' do
      node.associate(:cat, strength: 5.0)
      expect(node.association_strength(:cat)).to eq(constants::ASSOCIATION_CEILING)
    end

    it 'trims excess associations' do
      (constants::MAX_ASSOCIATIONS + 5).times { |i| node.associate(:"concept_#{i}") }
      expect(node.associations.size).to be <= constants::MAX_ASSOCIATIONS
    end
  end

  describe '#strengthen_association' do
    it 'increases association strength' do
      node.associate(:cat)
      initial = node.association_strength(:cat)
      node.strengthen_association(:cat)
      expect(node.association_strength(:cat)).to be > initial
    end

    it 'caps at ceiling' do
      node.associate(:cat, strength: constants::ASSOCIATION_CEILING)
      node.strengthen_association(:cat)
      expect(node.association_strength(:cat)).to eq(constants::ASSOCIATION_CEILING)
    end

    it 'does nothing for unknown associations' do
      node.strengthen_association(:unknown)
      expect(node.associations).to be_empty
    end
  end

  describe '#decay_associations' do
    it 'reduces association strengths' do
      node.associate(:cat)
      initial = node.association_strength(:cat)
      node.decay_associations
      expect(node.association_strength(:cat)).to be < initial
    end

    it 'floors at minimum' do
      node.associate(:cat, strength: constants::ASSOCIATION_FLOOR)
      node.decay_associations
      expect(node.association_strength(:cat)).to eq(constants::ASSOCIATION_FLOOR)
    end
  end

  describe '#decay_activation' do
    it 'reduces activation' do
      node.prime
      initial = node.activation
      node.decay_activation
      expect(node.activation).to be < initial
    end

    it 'floors at zero' do
      node.activation = 0.01
      node.decay_activation
      expect(node.activation).to eq(0.0)
    end

    it 'clears prime source when not primed' do
      node.prime(source: :test)
      10.times { node.decay_activation }
      expect(node.prime_source).to be_nil
    end
  end

  describe '#prime' do
    it 'increases activation' do
      node.prime
      expect(node.activation).to eq(constants::PRIME_BOOST)
    end

    it 'accepts custom boost' do
      node.prime(boost: 0.5)
      expect(node.activation).to eq(0.5)
    end

    it 'records source' do
      node.prime(source: :visual)
      expect(node.prime_source).to eq(:visual)
    end

    it 'caps activation at 1.0' do
      node.prime(boost: 0.8)
      node.prime(boost: 0.8)
      expect(node.activation).to eq(1.0)
    end
  end

  describe '#associated_names' do
    it 'returns list of associated concept names' do
      node.associate(:cat)
      node.associate(:bone)
      expect(node.associated_names).to contain_exactly(:cat, :bone)
    end
  end

  describe '#to_h' do
    it 'returns all fields' do
      h = node.to_h
      expect(h).to include(:name, :domain, :activation, :primed, :prime_source, :associations)
    end
  end
end
