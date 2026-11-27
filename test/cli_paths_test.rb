# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "../lib/gob/cli"

class CLIPathsTest < Minitest::Test
  SOURCE = <<~GOB
    module Main
      def main
      end
    end
  GOB

  def test_fmt_writes_in_place_and_takes_a_directory
    in_tree do |dir|
      unformatted = "module Main\n  def main\n    x = [1, 2]\n  end\nend\n"
      File.write("#{dir}/src/a.gob", unformatted)

      Gob::CLI.start(["fmt", "#{dir}/src"])

      assert_includes File.read("#{dir}/src/a.gob"), "Array[int].new(1, 2)"
      refute_includes File.read("#{dir}/src/a.gob"), "[1, 2]"
    end
  end

  def test_fmt_takes_no_write_option
    refute Gob::CLI::Commands::Fmt.commands["fmt"].options.key?(:write)
  end

  def test_vet_takes_a_directory
    in_tree do |dir|
      Gob::CLI.start(["vet", "#{dir}/src"])
    end
  end

  def test_vet_rejects_a_directory_with_no_gob_files
    in_tree do |dir|
      FileUtils.mkdir_p("#{dir}/empty")

      assert_raises(Thor::Error) { Gob::CLI::Commands::Vet.new.vet("#{dir}/empty") }
    end
  end

  def test_transpile_mirrors_a_tree_into_an_output_directory
    in_tree do |dir|
      Gob::CLI.start(["transpile", "#{dir}/src", "-o", "#{dir}/build"])

      assert_path_exists "#{dir}/build/a.go"
      assert_path_exists "#{dir}/build/nested/b.go"
      assert_includes File.read("#{dir}/build/nested/b.go"), "package main"
    end
  end

  def test_transpile_without_output_writes_go_siblings
    in_tree do |dir|
      Gob::CLI.start(["transpile", "#{dir}/src"])

      assert_path_exists "#{dir}/src/a.go"
      assert_path_exists "#{dir}/src/nested/b.go"
    end
  end

  private

    def in_tree
      Dir.mktmpdir do |dir|
        FileUtils.mkdir_p("#{dir}/src/nested")
        File.write("#{dir}/src/a.gob", SOURCE)
        File.write("#{dir}/src/nested/b.gob", SOURCE)

        yield dir
      end
    end
end
