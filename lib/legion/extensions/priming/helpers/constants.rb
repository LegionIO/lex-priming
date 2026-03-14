# frozen_string_literal: true

module Legion
  module Extensions
    module Priming
      module Helpers
        module Constants
          # Base activation boost from a prime
          PRIME_BOOST = 0.3

          # How fast priming decays per tick
          PRIME_DECAY = 0.08

          # Spreading activation factor (each hop reduces by this ratio)
          SPREAD_FACTOR = 0.5

          # Maximum hops for spreading activation
          MAX_SPREAD_HOPS = 3

          # Minimum activation to be considered primed
          PRIME_THRESHOLD = 0.1

          # Maximum concepts in the network
          MAX_CONCEPTS = 500

          # Maximum associations per concept
          MAX_ASSOCIATIONS = 20

          # Maximum active primes at once
          MAX_ACTIVE_PRIMES = 100

          # Default association strength between new connections
          DEFAULT_ASSOCIATION_STRENGTH = 0.5

          # Strengthening factor when association is activated
          ASSOCIATION_STRENGTHEN = 0.05

          # Weakening factor for unused associations
          ASSOCIATION_DECAY = 0.01

          # Association strength floor (never fully disconnect)
          ASSOCIATION_FLOOR = 0.05

          # Association strength ceiling
          ASSOCIATION_CEILING = 1.0
        end
      end
    end
  end
end
