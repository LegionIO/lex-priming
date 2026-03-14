# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Priming::Runners::Priming do
  let(:runner) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  before do
    runner.add_concept(name: :dog, domain: :animals)
    runner.add_concept(name: :cat, domain: :animals)
    runner.add_concept(name: :car, domain: :vehicles)
    runner.link_concepts(name_a: :dog, name_b: :cat, strength: 0.8)
  end

  describe '#prime_concept' do
    it 'primes a concept and returns its state' do
      result = runner.prime_concept(name: :dog)
      expect(result[:success]).to be true
      expect(result[:concept][:activation]).to be > 0
      expect(result[:concept][:primed]).to be true
    end

    it 'spreads activation to linked concepts' do
      runner.prime_concept(name: :dog)
      cat_check = runner.check_primed(name: :cat)
      expect(cat_check[:primed]).to be true
    end

    it 'does not spread to unlinked concepts' do
      runner.prime_concept(name: :dog)
      car_check = runner.check_primed(name: :car)
      expect(car_check[:primed]).to be false
    end

    it 'accepts custom boost' do
      result = runner.prime_concept(name: :dog, boost: 0.1, spread: false)
      expect(result[:concept][:activation]).to eq(0.1)
    end

    it 'auto-creates concepts if needed' do
      result = runner.prime_concept(name: :fish)
      expect(result[:success]).to be true
    end
  end

  describe '#add_concept' do
    it 'adds a new concept' do
      result = runner.add_concept(name: :bird, domain: :animals)
      expect(result[:success]).to be true
      expect(result[:concept][:name]).to eq(:bird)
    end
  end

  describe '#link_concepts' do
    it 'links two concepts' do
      result = runner.link_concepts(name_a: :dog, name_b: :car)
      expect(result[:success]).to be true
      expect(result[:strength]).to be > 0
    end
  end

  describe '#update_priming' do
    it 'decays all activations' do
      runner.prime_concept(name: :dog)
      initial = runner.check_primed(name: :dog)[:activation]
      runner.update_priming
      after = runner.check_primed(name: :dog)[:activation]
      expect(after).to be < initial
    end

    it 'returns active prime count' do
      runner.prime_concept(name: :dog)
      result = runner.update_priming
      expect(result[:success]).to be true
      expect(result).to include(:active_primes, :concept_count)
    end
  end

  describe '#check_primed' do
    it 'returns priming status' do
      result = runner.check_primed(name: :dog)
      expect(result[:success]).to be true
      expect(result[:primed]).to be false
      expect(result[:activation]).to eq(0.0)
    end

    it 'shows primed after priming' do
      runner.prime_concept(name: :dog)
      result = runner.check_primed(name: :dog)
      expect(result[:primed]).to be true
    end
  end

  describe '#primed_concepts' do
    it 'returns all primed concepts' do
      runner.prime_concept(name: :dog)
      result = runner.primed_concepts
      expect(result[:success]).to be true
      expect(result[:count]).to be >= 1
    end

    it 'filters by domain' do
      runner.prime_concept(name: :dog)
      runner.prime_concept(name: :car, spread: false)
      animals = runner.primed_concepts(domain: :animals)
      vehicles = runner.primed_concepts(domain: :vehicles)
      expect(animals[:count]).to be >= 1
      expect(vehicles[:count]).to eq(1)
    end
  end

  describe '#strongest_primes' do
    it 'returns top primed concepts' do
      runner.prime_concept(name: :dog, boost: 0.9, spread: false)
      runner.prime_concept(name: :cat, boost: 0.3, spread: false)
      result = runner.strongest_primes(count: 1)
      expect(result[:primes].first[:name]).to eq(:dog)
    end
  end

  describe '#neighbors_for' do
    it 'returns linked concepts' do
      result = runner.neighbors_for(name: :dog)
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
      expect(result[:neighbors].first[:name]).to eq(:cat)
    end
  end

  describe '#priming_stats' do
    it 'returns network summary' do
      result = runner.priming_stats
      expect(result[:success]).to be true
      expect(result[:stats]).to include(:concept_count, :active_primes)
    end
  end
end
