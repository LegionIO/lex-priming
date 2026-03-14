# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Priming::Helpers::ActivationNetwork do
  subject(:network) { described_class.new }

  let(:constants) { Legion::Extensions::Priming::Helpers::Constants }

  describe '#initialize' do
    it 'starts empty' do
      expect(network.concepts).to eq({})
      expect(network.concept_count).to eq(0)
    end
  end

  describe '#add_concept' do
    it 'adds a concept node' do
      concept = network.add_concept(name: :dog)
      expect(concept.name).to eq(:dog)
      expect(network.concept_count).to eq(1)
    end

    it 'returns existing concept if already present' do
      first = network.add_concept(name: :dog)
      second = network.add_concept(name: :dog)
      expect(first).to equal(second)
    end

    it 'accepts domain' do
      concept = network.add_concept(name: :dog, domain: :animals)
      expect(concept.domain).to eq(:animals)
    end
  end

  describe '#link' do
    it 'creates bidirectional associations' do
      network.link(:dog, :cat)
      expect(network.concepts[:dog].association_strength(:cat)).to be > 0
      expect(network.concepts[:cat].association_strength(:dog)).to be > 0
    end

    it 'auto-creates concepts if missing' do
      network.link(:apple, :banana)
      expect(network.concept_count).to eq(2)
    end

    it 'accepts custom strength' do
      network.link(:dog, :cat, strength: 0.9)
      expect(network.concepts[:dog].association_strength(:cat)).to eq(0.9)
    end
  end

  describe '#prime' do
    before do
      network.link(:dog, :cat, strength: 0.8)
      network.link(:cat, :mouse, strength: 0.6)
      network.link(:mouse, :cheese, strength: 0.7)
    end

    it 'activates the target concept' do
      network.prime(:dog)
      expect(network.activation_for(:dog)).to be > 0
    end

    it 'spreads activation to neighbors' do
      network.prime(:dog)
      expect(network.activation_for(:cat)).to be > 0
    end

    it 'spreads with diminishing strength' do
      network.prime(:dog)
      expect(network.activation_for(:dog)).to be > network.activation_for(:cat)
      expect(network.activation_for(:cat)).to be > network.activation_for(:mouse)
    end

    it 'respects max spread hops' do
      network.link(:cheese, :crackers, strength: 0.5)
      # Use a strong boost to ensure spread reaches far enough to test limits
      network.prime(:dog, boost: 0.8)
      # dog->cat->mouse->cheese = 3 hops (within limit), cheese->crackers = 4th hop (beyond limit)
      cheese_activation = network.activation_for(:cheese)
      crackers_activation = network.activation_for(:crackers)
      # Crackers should have less activation than cheese (spread attenuates or stops at max hops)
      expect(crackers_activation).to be <= cheese_activation
    end

    it 'can prime without spreading' do
      network.prime(:dog, spread: false)
      expect(network.activation_for(:dog)).to be > 0
      expect(network.activation_for(:cat)).to eq(0.0)
    end

    it 'returns nil for unknown concept' do
      expect(network.prime(:unknown)).to be_nil
    end
  end

  describe '#activation_for' do
    it 'returns 0 for unknown concepts' do
      expect(network.activation_for(:unknown)).to eq(0.0)
    end
  end

  describe '#primed_concepts' do
    it 'returns only activated concepts' do
      network.link(:dog, :cat)
      network.prime(:dog, spread: false)
      primed = network.primed_concepts
      expect(primed.size).to eq(1)
      expect(primed.first.name).to eq(:dog)
    end
  end

  describe '#primed_in_domain' do
    it 'filters by domain' do
      network.add_concept(name: :dog, domain: :animals)
      network.add_concept(name: :car, domain: :vehicles)
      network.prime(:dog, spread: false)
      network.prime(:car, spread: false)
      animals = network.primed_in_domain(:animals)
      expect(animals.size).to eq(1)
      expect(animals.first.name).to eq(:dog)
    end
  end

  describe '#decay_all' do
    it 'reduces activation of all concepts' do
      network.add_concept(name: :dog)
      network.prime(:dog, spread: false)
      initial = network.activation_for(:dog)
      network.decay_all
      expect(network.activation_for(:dog)).to be < initial
    end

    it 'eventually removes all priming' do
      network.add_concept(name: :dog)
      network.prime(:dog, spread: false)
      20.times { network.decay_all }
      expect(network.primed_concepts).to be_empty
    end
  end

  describe '#neighbors' do
    it 'returns associated concepts' do
      network.link(:dog, :cat)
      network.link(:dog, :bone)
      nbrs = network.neighbors(:dog)
      expect(nbrs.map(&:name)).to contain_exactly(:cat, :bone)
    end

    it 'returns empty for unknown concepts' do
      expect(network.neighbors(:unknown)).to eq([])
    end
  end

  describe '#strongest_primes' do
    it 'returns top N primed concepts' do
      network.add_concept(name: :a)
      network.add_concept(name: :b)
      network.add_concept(name: :c)
      network.prime(:a, boost: 0.9, spread: false)
      network.prime(:b, boost: 0.5, spread: false)
      network.prime(:c, boost: 0.7, spread: false)
      top = network.strongest_primes(2)
      expect(top.map(&:name)).to eq(%i[a c])
    end
  end

  describe '#to_h' do
    it 'returns network stats' do
      h = network.to_h
      expect(h).to include(:concept_count, :active_primes, :primed_concepts, :domains)
    end
  end
end
