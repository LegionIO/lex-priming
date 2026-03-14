# lex-priming

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-priming`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::Priming`

## Purpose

Associative activation network for cognitive priming. Maintains a network of concept nodes linked by association strengths. Priming a concept boosts its activation and spreads that activation to neighboring nodes via BFS (up to `MAX_SPREAD_HOPS` hops), with each hop attenuated by `SPREAD_FACTOR` * association strength. Concepts decay each tick. Supports domain-filtered primed concept retrieval and association strengthening.

## Gem Info

- **Homepage**: https://github.com/LegionIO/lex-priming
- **License**: MIT
- **Ruby**: >= 3.4

## File Structure

```
lib/legion/extensions/priming/
  version.rb
  client.rb
  helpers/
    constants.rb          # PRIME_BOOST, PRIME_DECAY, SPREAD_FACTOR, thresholds, limits
    concept_node.rb       # ConceptNode — named node with activation and associations
    activation_network.rb # ActivationNetwork — BFS spread, decay, query
  runners/
    priming.rb            # Runner module
spec/
  helpers/constants_spec.rb
  helpers/concept_node_spec.rb
  helpers/activation_network_spec.rb
  runners/priming_spec.rb
  client_spec.rb
```

## Key Constants

From `Helpers::Constants`:
- `PRIME_BOOST = 0.3`, `PRIME_DECAY = 0.08`, `PRIME_THRESHOLD = 0.1`
- `SPREAD_FACTOR = 0.5`, `MAX_SPREAD_HOPS = 3`
- `DEFAULT_ASSOCIATION_STRENGTH = 0.5`
- `MAX_CONCEPTS` (capacity limit)

## Runners

| Method | Key Parameters | Returns |
|---|---|---|
| `prime_concept` | `name:`, `boost:`, `source:`, `spread: true` | `{ success:, concept:, active_primes: }` |
| `add_concept` | `name:`, `domain: :general` | `{ success:, concept: }` |
| `link_concepts` | `name_a:`, `name_b:`, `strength:` | `{ success:, name_a:, name_b:, strength: }` |
| `update_priming` | — | decay tick — `{ success:, active_primes:, concept_count: }` |
| `check_primed` | `name:` | `{ success:, name:, activation:, primed:, source: }` |
| `primed_concepts` | `domain: nil` | `{ success:, concepts:, count: }` |
| `strongest_primes` | `count: 5` | `{ success:, primes:, count: }` sorted by activation |
| `neighbors_for` | `name:` | `{ success:, name:, neighbors:, count: }` with activation and primed status |
| `priming_stats` | — | concept count, active prime count, primed concept list, domains |

## Helpers

### `Helpers::ConceptNode`
Named activation node: `name`, `domain`, `activation` (float, starts 0), `prime_source`, `associations` (hash of name -> strength). `prime(boost:, source:)` adds boost clamped to 1.0. `decay_activation` subtracts `PRIME_DECAY`. `primed?` = activation >= `PRIME_THRESHOLD`. `associate(name, strength:)` stores in `@associations`. `association_strength(name)` returns stored strength or 0. `strengthen_association(name)` increments by small delta.

### `Helpers::ActivationNetwork`
Manages `@concepts` hash (name -> ConceptNode). `add_concept(name:, domain:)` idempotent — returns existing if present. `link(name_a, name_b, strength:)` creates both nodes if absent and sets bidirectional association. `prime(name, boost:, source:, spread:)` primes source node and runs BFS spread. `spread_activation` BFS: each hop computes `spread_boost = current_boost * SPREAD_FACTOR * association_strength`, skips if below `PRIME_THRESHOLD`, strengthens traversed associations. `decay_all` calls `decay_activation` and `decay_associations` on all nodes. `strongest_primes(count)` sorts primed concepts by activation descending.

## Integration Points

- `prime_concept` accepts domain signals from `lex-attention` (spotlight activations)
- `primed_concepts` output feeds `lex-memory` retrieval to bias toward contextually active concepts
- `strongest_primes` can seed `lex-curiosity` gap detection with pre-activated context
- `link_concepts` can mirror `lex-memory`'s Hebbian links for cross-system reinforcement
- `update_priming` called each tick via `lex-cortex` phase handler

## Development Notes

- BFS spread visits each concept only once per prime event (visited Set prevents loops)
- Spread is attenuated: `boost * SPREAD_FACTOR * strength` per hop, stops when below `PRIME_THRESHOLD`
- `add_concept` is idempotent — calling it twice for the same name returns the existing node
- `trim_concepts` evicts lowest-activation concepts when at capacity
- Activation does not have a hard ceiling from decay but is clamped at 1.0 on prime
- All state is in-memory; reset on process restart
