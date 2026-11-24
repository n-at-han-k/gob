# frozen_string_literal: true

require "rubocop"

module RuboCop
  module Gob
    module ConfigLoader
      module_function

      def config_path
        File.expand_path("config.yml", __dir__)
      end

      def config_store
        @config_store ||= begin
          store = RuboCop::ConfigStore.new
          store.options_config = config_path
          store
        end
      end

      def reset!
        @config_store = nil
      end
    end
  end
end
