# lex-priming

Associative activation network for the LegionIO cognitive architecture. Implements spreading activation priming across linked concept nodes.

## What It Does

Maintains a network of concept nodes connected by association strengths. When a concept is primed, its activation is boosted and that activation spreads through the network via BFS — each hop attenuated by the spread factor and association strength. Concepts decay each tick. Supports querying which concepts are currently primed, finding the strongest activations, and retrieving neighbors.

## Usage

```ruby
client = Legion::Extensions::Priming::Client.new

# Build the concept network
client.add_concept(name: :authentication, domain: :security)
client.add_concept(name: :credentials, domain: :security)
client.add_concept(name: :session_token, domain: :security)
client.link_concepts(name_a: :authentication, name_b: :credentials, strength: 0.8)
client.link_concepts(name_a: :credentials, name_b: :session_token, strength: 0.7)

# Prime a concept (activation spreads to neighbors)
client.prime_concept(name: :authentication, boost: 0.5, spread: true)

# Check which concepts are now active
client.primed_concepts
# => { success: true, concepts: [
#      { name: :authentication, activation: 0.5, domain: :security },
#      { name: :credentials, activation: 0.175, domain: :security },
#      { name: :session_token, activation: 0.031, domain: :security }
#    ], count: 3 }

# Top activations
client.strongest_primes(count: 3)

# Check a specific concept
client.check_primed(name: :credentials)
# => { success: true, name: :credentials, activation: 0.175, primed: true, source: :authentication }

# Each tick: decay activations
client.update_priming
client.priming_stats
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
