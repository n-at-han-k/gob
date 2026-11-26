# frozen_string_literal: true

module Gob
  class CLI
    module Completion
      SOURCE_EXTENSIONS = ["gob"].freeze

      module Schema
        module_function

        def call(name:, description:, version:, cli:)
          Thor::Completion::Builder.call(name:, description:, version:, cli:).tap do |schema|
            schema[:commands].each { customize_command(_1) }
          end
        end

        def customize_command(command)
          Array(command[:subcommands]).each { customize_command(_1) }
          flatten_default_subcommand(command)

          Array(command[:arguments]).each do |argument|
            next unless %w[file files].include?(argument[:name])

            argument[:completion] = {
              type: "file",
              extensions: SOURCE_EXTENSIONS
            }
          end
        end

        def flatten_default_subcommand(command)
          subcommands = command[:subcommands]
          return if subcommands.nil? || subcommands.empty?

          default = subcommands.find do |subcommand|
            subcommand[:name] == command[:name]
          end

          return unless default

          command.merge!(
            options: default[:options] || [],
            arguments: default[:arguments] || []
          )

          command.delete(:subcommands)
        end
      end

      class Bash < Thor::Completion::Bash
        private

          def format_completion_bash(completion)
            if (
              completion[:type] == "file" &&
              completion[:extensions]&.any?
            )
              pattern = completion[:extensions].map { |extension| "\\.#{Regexp.escape(extension)}$" }.join("|")

              "while IFS= read -r candidate; do\n" \
                "    COMPREPLY+=(\"$candidate\")\n" \
                "  done < <(compgen -f -- \"$cur\" | grep -E '#{pattern}')"
            else
              super
            end
          end
      end

      class Fish < Thor::Completion::Fish
        private

          def generate_command_completions(cmd, path)
            super
            argument = cmd[:arguments]&.first
            completion = argument&.dig(:completion)
            return unless completion&.dig(:type) == "file" && completion[:extensions]&.any?

            candidates = completion[:extensions].map do |extension|
              "(__fish_complete_suffix .#{extension} | string match -- \"*.#{extension}\")"
            end.join(" ")

            output << "complete -c #{name} -n #{quote_fish(build_condition(path))} -f -a #{quote_fish(candidates)}"
          end
      end

      module_function

      def generate(shell:, name:, description:, version:, cli:)
        schema = Schema.call(name:, description:, version:, cli:)

        case shell
        when "bash"
          Bash.new(schema).call
        when "zsh"
          Thor::Completion::ZSH.new(schema).call
        when "fish"
          Fish.new(schema).call
        else
          raise ArgumentError, "Unsupported shell: #{shell.inspect}"
        end
      end
    end
  end
end
