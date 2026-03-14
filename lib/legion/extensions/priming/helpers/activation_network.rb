# frozen_string_literal: true

module Legion
  module Extensions
    module Priming
      module Helpers
        class ActivationNetwork
          attr_reader :concepts

          def initialize
            @concepts = {}
          end

          def add_concept(name:, domain: :general)
            @concepts[name] ||= ConceptNode.new(name: name, domain: domain)
            trim_concepts
            @concepts[name]
          end

          def link(name_a, name_b, strength: Constants::DEFAULT_ASSOCIATION_STRENGTH)
            add_concept(name: name_a) unless @concepts.key?(name_a)
            add_concept(name: name_b) unless @concepts.key?(name_b)
            @concepts[name_a].associate(name_b, strength: strength)
            @concepts[name_b].associate(name_a, strength: strength)
          end

          def prime(name, boost: Constants::PRIME_BOOST, source: nil, spread: true)
            concept = @concepts[name]
            return nil unless concept

            concept.prime(boost: boost, source: source)
            spread_activation(name, boost) if spread
            concept
          end

          def activation_for(name)
            concept = @concepts[name]
            concept ? concept.activation : 0.0
          end

          def primed_concepts
            @concepts.values.select(&:primed?)
          end

          def primed_in_domain(domain)
            @concepts.values.select { |c| c.domain == domain && c.primed? }
          end

          def decay_all
            @concepts.each_value do |concept|
              concept.decay_activation
              concept.decay_associations
            end
          end

          def neighbors(name)
            concept = @concepts[name]
            return [] unless concept

            concept.associated_names.filter_map { |n| @concepts[n] }
          end

          def concept_count
            @concepts.size
          end

          def active_prime_count
            primed_concepts.size
          end

          def strongest_primes(count = 5)
            primed_concepts.sort_by { |c| -c.activation }.first(count)
          end

          def to_h
            {
              concept_count:   @concepts.size,
              active_primes:   active_prime_count,
              primed_concepts: primed_concepts.map { |c| { name: c.name, activation: c.activation.round(4) } },
              domains:         @concepts.values.map(&:domain).uniq
            }
          end

          private

          def spread_activation(source_name, initial_boost)
            visited = Set.new([source_name])
            queue = [[source_name, initial_boost, 0]]

            while queue.any?
              current_name, current_boost, depth = queue.shift
              next if depth >= Constants::MAX_SPREAD_HOPS

              concept = @concepts[current_name]
              next unless concept

              concept.associated_names.each do |neighbor_name|
                next if visited.include?(neighbor_name)

                visited.add(neighbor_name)
                neighbor = @concepts[neighbor_name]
                next unless neighbor

                strength = concept.association_strength(neighbor_name)
                spread_boost = current_boost * Constants::SPREAD_FACTOR * strength
                next if spread_boost < Constants::PRIME_THRESHOLD

                neighbor.prime(boost: spread_boost, source: source_name)
                concept.strengthen_association(neighbor_name)
                queue << [neighbor_name, spread_boost, depth + 1]
              end
            end
          end

          def trim_concepts
            return unless @concepts.size > Constants::MAX_CONCEPTS

            sorted = @concepts.sort_by { |_, c| c.activation }
            excess = @concepts.size - Constants::MAX_CONCEPTS
            sorted.first(excess).each { |name, _| @concepts.delete(name) } # rubocop:disable Style/HashEachMethods
          end
        end
      end
    end
  end
end
