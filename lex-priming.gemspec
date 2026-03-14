# frozen_string_literal: true

require_relative 'lib/legion/extensions/priming/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-priming'
  spec.version       = Legion::Extensions::Priming::VERSION
  spec.authors       = ['Matthew Iverson']
  spec.email         = ['matt@iverson.io']

  spec.summary       = 'Spreading activation and priming for LegionIO'
  spec.description   = 'Models spreading activation in semantic networks — stimuli prime related ' \
                       'concepts, lowering their activation threshold and speeding future access.'
  spec.homepage      = 'https://github.com/LegionIO/lex-priming'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.files         = Dir['lib/**/*', 'LICENSE', 'README.md']
  spec.require_paths = ['lib']
  spec.metadata['rubygems_mfa_required'] = 'true'
end
