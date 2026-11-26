# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"
require_relative "../lib/gob/cli"
require_relative "../lib/gob/version"

class CLIInitTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  LIB = File.join(ROOT, "lib")
  EXECUTABLE = File.join(ROOT, "exe/gob")

  GO = ["go"].find do |candidate|
    Open3.capture3(candidate, "version").last.success?
  rescue Errno::ENOENT
    false
  end

  def test_initialises_a_gob_project
    skip "Go is required" unless GO

    Dir.mktmpdir do |directory|
      _stdout, stderr, status = gob(directory, "init", "example.com/demo")
      assert status.success?, stderr
      assert_match(/^module example\.com\/demo$/, File.read(File.join(directory, "go.mod")))
      assert_includes File.read(File.join(directory, "main.gob")), "Ey up gobbah! What's cookin'?"
      assert_includes File.read(File.join(directory, "Gemfile")), %(gem "gob-lang", "~> #{Gob::VERSION}")
      assert_includes File.read(File.join(directory, ".gitignore")), "/gob"
      refute File.exist?(File.join(directory, "flake.nix"))
    end
  end

  def test_preserves_an_existing_go_mod_and_creates_project_files
    skip "Go is required" unless GO

    Dir.mktmpdir do |directory|
      go_mod = File.join(directory, "go.mod")
      File.write(go_mod, "module existing\n")
      _stdout, stderr, status = gob(directory, "init", "example.com/demo")
      assert status.success?, stderr
      assert_equal "module existing\n", File.read(go_mod)
      assert File.exist?(File.join(directory, "Gemfile"))
      assert File.exist?(File.join(directory, "main.gob"))
    end
  end

  def test_merges_gob_into_an_existing_gemfile_and_gitignore
    skip "Go is required" unless GO

    Dir.mktmpdir do |directory|
      gemfile = File.join(directory, "Gemfile")
      gitignore = File.join(directory, ".gitignore")
      File.write(gemfile, %(source "https://rubygems.org"\ngem "rack"\n))
      File.write(gitignore, "/vendor\n")

      _stdout, stderr, status = gob(directory, "init", "example.com/demo")
      assert status.success?, stderr
      assert_match(/gem "rack"/, File.read(gemfile))
      assert_match(/gem "gob-lang"/, File.read(gemfile))
      assert_match(%r{/vendor}, File.read(gitignore))
      assert_match(%r{/gob}, File.read(gitignore))
    end
  end

  def test_refuses_to_overwrite_existing_project_files
    skip "Go is required" unless GO

    Dir.mktmpdir do |directory|
      main = File.join(directory, "main.gob")
      File.write(main, "existing\n")
      _stdout, stderr, status = gob(directory, "init", "example.com/demo")
      refute status.success?
      assert_match(/main\.gob already exists/, stderr)
      assert_equal "existing\n", File.read(main)
      refute File.exist?(File.join(directory, "go.mod"))
    end
  end

  def test_force_overwrites_generated_files_without_replacing_go_mod
    skip "Go is required" unless GO

    Dir.mktmpdir do |directory|
      go_mod = File.join(directory, "go.mod")
      main = File.join(directory, "main.gob")
      File.write(go_mod, "module existing\n")
      File.write(main, "existing\n")
      _stdout, stderr, status = gob(directory, "init", "example.com/demo", "--force")
      assert status.success?, stderr
      assert_equal "module existing\n", File.read(go_mod)
      assert_includes File.read(main), "Ey up gobbah! What's cookin'?"
    end
  end

  def test_nix_option_writes_development_files_without_running_bundix
    skip "Go is required" unless GO

    Dir.mktmpdir do |directory|
      _stdout, stderr, status = gob(directory, "init", "example.com/demo", "--nix")
      assert status.success?, stderr
      assert File.exist?(File.join(directory, "flake.nix"))
      assert File.exist?(File.join(directory, ".envrc"))
      refute File.exist?(File.join(directory, "gemset.nix"))
    end
  end

  def test_templates_are_packaged_in_the_gem
    specification = Gem::Specification.load(File.join(ROOT, "gob-lang.gemspec"))

    assert_includes specification.files, "lib/gob/templates/Gemfile.tt"
    assert_includes specification.files, "lib/gob/templates/flake.nix.tt"
    assert_includes specification.files, "lib/gob/templates/main.gob.tt"
  end

  private

    def gob(directory, *arguments)
      Open3.capture3(RbConfig.ruby, "-I", LIB, EXECUTABLE, *arguments, chdir: directory)
    end
end
