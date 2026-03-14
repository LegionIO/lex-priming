# frozen_string_literal: true

module Legion
  module Extensions
    module Priming
      module Helpers
        class ConceptNode
          attr_reader :name, :domain, :associations
          attr_accessor :activation, :prime_source

          def initialize(name:, domain: :general)
            @name         = name
            @domain       = domain
            @activation   = 0.0
            @prime_source = nil
            @associations = {}
          end

          def primed?
            @activation >= Constants::PRIME_THRESHOLD
          end

          def associate(other_name, strength: Constants::DEFAULT_ASSOCIATION_STRENGTH)
            @associations[other_name] = strength.clamp(Constants::ASSOCIATION_FLOOR, Constants::ASSOCIATION_CEILING)
            trim_associations
          end

          def strengthen_association(other_name)
            return unless @associations.key?(other_name)

            @associations[other_name] = [
              @associations[other_name] + Constants::ASSOCIATION_STRENGTHEN,
              Constants::ASSOCIATION_CEILING
            ].min
          end

          def decay_associations
            @associations.each_key do |key|
              @associations[key] = [
                @associations[key] - Constants::ASSOCIATION_DECAY,
                Constants::ASSOCIATION_FLOOR
              ].max
            end
          end

          def decay_activation
            @activation = [@activation - Constants::PRIME_DECAY, 0.0].max
            @prime_source = nil unless primed?
          end

          def prime(boost: Constants::PRIME_BOOST, source: nil)
            @activation = [@activation + boost, 1.0].min
            @prime_source = source
          end

          def association_strength(other_name)
            @associations[other_name] || 0.0
          end

          def associated_names
            @associations.keys
          end

          def to_h
            {
              name:         @name,
              domain:       @domain,
              activation:   @activation.round(4),
              primed:       primed?,
              prime_source: @prime_source,
              associations: @associations.transform_values { |v| v.round(4) }
            }
          end

          private

          def trim_associations
            return unless @associations.size > Constants::MAX_ASSOCIATIONS

            sorted = @associations.sort_by { |_, v| v }
            excess = @associations.size - Constants::MAX_ASSOCIATIONS
            sorted.first(excess).each { |name, _| @associations.delete(name) } # rubocop:disable Style/HashEachMethods
          end
        end
      end
    end
  end
end
