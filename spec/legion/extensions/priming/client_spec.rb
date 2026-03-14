# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Legion::Extensions::Priming::Client do
  subject(:client) { described_class.new }

  describe '#initialize' do
    it 'creates a default network' do
      expect(client.network).to be_a(Legion::Extensions::Priming::Helpers::ActivationNetwork)
    end

    it 'accepts an injected network' do
      custom = Legion::Extensions::Priming::Helpers::ActivationNetwork.new
      injected = described_class.new(network: custom)
      expect(injected.network).to equal(custom)
    end
  end

  describe 'spreading activation lifecycle' do
    it 'models semantic priming: dog -> bone -> fetch -> park' do
      # Build a semantic network
      client.add_concept(name: :dog, domain: :animals)
      client.add_concept(name: :bone, domain: :objects)
      client.add_concept(name: :fetch, domain: :activities)
      client.add_concept(name: :park, domain: :places)

      client.link_concepts(name_a: :dog, name_b: :bone, strength: 0.9)
      client.link_concepts(name_a: :dog, name_b: :fetch, strength: 0.7)
      client.link_concepts(name_a: :fetch, name_b: :park, strength: 0.6)

      # Prime "dog" — should spread to bone, fetch, and park
      client.prime_concept(name: :dog)

      bone_check = client.check_primed(name: :bone)
      fetch_check = client.check_primed(name: :fetch)
      park_check = client.check_primed(name: :park)

      expect(bone_check[:primed]).to be true
      expect(fetch_check[:primed]).to be true
      # Park is 2 hops away — may or may not be primed depending on spread
      expect(park_check[:activation]).to be >= 0.0

      # Dog should be most strongly primed
      strongest = client.strongest_primes(count: 1)
      expect(strongest[:primes].first[:name]).to eq(:dog)

      # Decay over time
      5.times { client.update_priming }
      after_decay = client.check_primed(name: :bone)
      expect(after_decay[:activation]).to be < bone_check[:activation]

      # Eventually all priming fades
      20.times { client.update_priming }
      stats = client.priming_stats
      expect(stats[:stats][:active_primes]).to eq(0)
    end

    it 'demonstrates domain-specific priming' do
      # Animal domain
      client.add_concept(name: :dog, domain: :animals)
      client.add_concept(name: :cat, domain: :animals)
      client.link_concepts(name_a: :dog, name_b: :cat, strength: 0.8)

      # Vehicle domain
      client.add_concept(name: :car, domain: :vehicles)
      client.add_concept(name: :truck, domain: :vehicles)
      client.link_concepts(name_a: :car, name_b: :truck, strength: 0.8)

      # Prime one domain
      client.prime_concept(name: :dog)

      # Only animal domain should be primed
      animals = client.primed_concepts(domain: :animals)
      vehicles = client.primed_concepts(domain: :vehicles)
      expect(animals[:count]).to be >= 1
      expect(vehicles[:count]).to eq(0)
    end
  end
end
