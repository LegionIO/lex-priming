# frozen_string_literal: true

module Legion
  module Extensions
    module Priming
      class Client
        include Runners::Priming

        attr_reader :network

        def initialize(network: nil, **)
          @network = network || Helpers::ActivationNetwork.new
        end
      end
    end
  end
end
