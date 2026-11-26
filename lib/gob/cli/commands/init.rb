# frozen_string_literal: true

require_relative "../base"
require_relative "../../go/runner"

module Gob
  class CLI
    module Commands
      class Init < Base
        include Thor::Actions

        default_command :init
        desc "init [MODULE]", "Initialise or updates a Gob project"
        long_desc "Creates missing project files and merges Gob into an existing Gemfile, .gitignore, and .envrc. With --nix, writes flake.nix when it is missing."
        method_option :nix, type: :boolean, default: false, desc: "Generate Nix development files"
        method_option :force, type: :boolean, default: false, desc: "Overwrite main.gob"

        def self.source_root
          File.expand_path("../../templates", __dir__)
        end

        def init(module_path = nil)
          @module_path = module_path
          self.destination_root = Dir.pwd

          prepare_main
          template "main.gob.tt", "main.gob", force: options[:force] if options[:force] || !File.exist?("main.gob")
          prepare_go_mod
          merge_gemfile
          merge_gitignore

          if options[:nix]
            merge_envrc
            template "flake.nix.tt", "flake.nix" unless File.exist?("flake.nix")
          end

          say "Gob project ready", :green
          say "Run `nix develop --command bundle lock`, then `nix develop --command bundix -l`" if options[:nix]
        end

        private

          def prepare_main
            return unless File.exist?("main.gob")
            return if options[:force]

            raise Thor::Error, "main.gob already exists"
          end

          def prepare_go_mod
            return if File.exist?("go.mod")

            exit 1 unless Gob::Go::Runner.mod_init(@module_path)
          end

          def merge_gemfile
            unless File.exist?("Gemfile")
              template "Gemfile.tt", "Gemfile"
              return
            end

            contents = File.read("Gemfile")
            append_to_file "Gemfile", %(\nsource "https://rubygems.org"\n) unless contents.include?('source "https://rubygems.org"')
            append_to_file "Gemfile", %(\ngem "gob-lang", "~> #{Gob::VERSION}"\n) unless contents.match?(/^\s*gem\s+["']gob-lang["']/)
          end

          def merge_gitignore
            unless File.exist?(".gitignore")
              template "gitignore.tt", ".gitignore"
              return
            end

            contents = File.read(".gitignore")
            append_to_file ".gitignore", "/gob\n" unless contents.lines.any? { |line| line.strip == "/gob" }
          end

          def merge_envrc
            unless File.exist?(".envrc")
              template "envrc.tt", ".envrc"
              return
            end

            contents = File.read(".envrc")
            append_to_file ".envrc", %(export BUNDLE_GEMFILE="$PWD/Gemfile"\n) unless contents.include?("BUNDLE_GEMFILE")
            append_to_file ".envrc", "use flake\n" unless contents.lines.any? { |line| line.strip == "use flake" }
          end

          def project_name
            base = @module_path&.split("/")&.last || File.basename(Dir.pwd)
            name = base.downcase.gsub(/[^a-z0-9_-]+/, "-").gsub(/-+/, "-").delete_prefix("-").delete_suffix("-")
            name.empty? ? "gob" : name
          end
      end
    end
  end
end
