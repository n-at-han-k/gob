# frozen_string_literal: true

module Gob
  # Announces each stage of the pipeline as it starts.
  #
  # Steps go to stderr so `gob transpile` can still pipe Go source on stdout.
  module Reporter
    module_function

    def step(message)
      warn "gob: #{message}"
    end
  end
end
