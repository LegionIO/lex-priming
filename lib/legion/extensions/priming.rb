# frozen_string_literal: true

require_relative 'priming/version'
require_relative 'priming/helpers/constants'
require_relative 'priming/helpers/concept_node'
require_relative 'priming/helpers/activation_network'
require_relative 'priming/runners/priming'
require_relative 'priming/client'

module Legion
  module Extensions
    module Priming
      extend Legion::Extensions::Core if defined?(Legion::Extensions::Core)
    end
  end
end
