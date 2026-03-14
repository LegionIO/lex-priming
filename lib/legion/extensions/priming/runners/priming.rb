# frozen_string_literal: true

module Legion
  module Extensions
    module Priming
      module Runners
        module Priming
          include Legion::Extensions::Helpers::Lex

          def network
            @network ||= Helpers::ActivationNetwork.new
          end

          def prime_concept(name:, boost: nil, source: nil, spread: true, **)
            boost ||= Helpers::Constants::PRIME_BOOST
            network.add_concept(name: name) unless network.concepts.key?(name)
            concept = network.prime(name, boost: boost, source: source, spread: spread)
            return { success: false, reason: :not_found } unless concept

            Legion::Logging.debug "[priming] primed #{name} activation=#{concept.activation.round(4)} spread=#{spread}"
            { success: true, concept: concept.to_h, active_primes: network.active_prime_count }
          end

          def add_concept(name:, domain: :general, **)
            concept = network.add_concept(name: name, domain: domain)
            { success: true, concept: concept.to_h }
          end

          def link_concepts(name_a:, name_b:, strength: nil, **)
            strength ||= Helpers::Constants::DEFAULT_ASSOCIATION_STRENGTH
            network.link(name_a, name_b, strength: strength)
            Legion::Logging.debug "[priming] linked #{name_a} <-> #{name_b} strength=#{strength}"
            { success: true, name_a: name_a, name_b: name_b, strength: strength }
          end

          def update_priming(**)
            network.decay_all
            primed = network.primed_concepts
            Legion::Logging.debug "[priming] tick: concepts=#{network.concept_count} active=#{primed.size}"
            { success: true, active_primes: primed.size, concept_count: network.concept_count }
          end

          def check_primed(name:, **)
            activation = network.activation_for(name)
            concept = network.concepts[name]
            {
              success:    true,
              name:       name,
              activation: activation.round(4),
              primed:     activation >= Helpers::Constants::PRIME_THRESHOLD,
              source:     concept&.prime_source
            }
          end

          def primed_concepts(domain: nil, **)
            concepts = domain ? network.primed_in_domain(domain) : network.primed_concepts
            {
              success:  true,
              concepts: concepts.map { |c| { name: c.name, activation: c.activation.round(4), domain: c.domain } },
              count:    concepts.size
            }
          end

          def strongest_primes(count: 5, **)
            top = network.strongest_primes(count)
            {
              success: true,
              primes:  top.map { |c| { name: c.name, activation: c.activation.round(4), domain: c.domain } },
              count:   top.size
            }
          end

          def neighbors_for(name:, **)
            nbrs = network.neighbors(name)
            {
              success:   true,
              name:      name,
              neighbors: nbrs.map { |c| { name: c.name, activation: c.activation.round(4), primed: c.primed? } },
              count:     nbrs.size
            }
          end

          def priming_stats(**)
            { success: true, stats: network.to_h }
          end
        end
      end
    end
  end
end
