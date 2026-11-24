# frozen_string_literal: true

module Gob
  module Validation
    module Rules
      class Cop < RuboCop::Cop::Base
        exclude_from_registry

        def self.badge
          @badge ||= RuboCop::Cop::Badge.parse("Gob/#{name.split("::").last}")
        end
      end
    end
  end
end
