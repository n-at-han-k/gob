# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"
require_relative "../lib/gob/cli"

class CLICompletionTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  LIB = File.join(ROOT, "lib")
  EXECUTABLE = File.join(ROOT, "exe/gob")

  BASH = ["bash"].find do |candidate|
    Open3.capture3(candidate, "-c", "type compgen complete >/dev/null 2>&1").last.success?
  rescue Errno::ENOENT
    false
  end

  FISH = ["fish"].find do |candidate|
    Open3.capture3(candidate, "--version").last.success?
  rescue Errno::ENOENT
    false
  end
  def test_bash_completion_only_suggests_gob_source_files
    skip "Bash with programmable completion is required" unless BASH
    script = completion("bash")

    Dir.mktmpdir do |directory|
      FileUtils.touch(%w[hello.gob hello.go notes.txt].map { |name| File.join(directory, name) })

      stdout, stderr, status = Open3.capture3(
        BASH,
        "-c",
        <<~BASH,
          #{script}
          COMP_WORDS=(gob build hello)
          COMP_CWORD=2
          _gob
          printf '%s\\n' "${COMPREPLY[@]}"
        BASH
        chdir: directory
      )

      assert status.success?, stderr
      assert_equal "hello.gob\n", stdout
    end
  end

  def test_bash_output_option_still_completes_any_file
    skip "Bash with programmable completion is required" unless BASH
    script = completion("bash")

    Dir.mktmpdir do |directory|
      FileUtils.touch(%w[hello.gob hello.go].map { |name| File.join(directory, name) })

      stdout, stderr, status = Open3.capture3(
        BASH,
        "-c",
        <<~BASH,
          #{script}
          COMP_WORDS=(gob transpile --output hello)
          COMP_CWORD=3
          _gob
          printf '%s\\n' "${COMPREPLY[@]}"
        BASH
        chdir: directory
      )

      assert status.success?, stderr
      assert_equal %w[hello.go hello.gob], stdout.lines.map(&:chomp).sort
    end
  end

  def test_zsh_completion_restricts_source_arguments
    script = completion("zsh")
    assert_includes script, "#compdef gob"
    assert_includes script, "_files -g '{*.gob}'"
    refute_includes script, "execute"
  end

  def test_fish_completion_restricts_source_arguments
    script = completion("fish")
    assert_includes script, "__fish_seen_subcommand_from run"
    assert_includes script, "__fish_complete_suffix .gob"
    assert_includes script, 'string match -- "*.gob"'
  end

  def test_fish_completion_only_suggests_gob_source_files
    skip "Fish is required" unless FISH
    script = completion("fish")

    Dir.mktmpdir do |directory|
      FileUtils.touch(%w[hello.gob hello.go notes.txt].map { |name| File.join(directory, name) })

      stdout, stderr, status = Open3.capture3(
        FISH,
        "-c",
        "#{script}\ncomplete -C 'gob build hello'",
        chdir: directory
      )

      assert status.success?, stderr
      assert_equal "hello.gob\n", stdout
    end
  end

  def test_completion_shell_values_are_limited_to_posix_shells
    script = completion("bash")
    assert_includes script, 'compgen -W "bash zsh fish"'
    refute_includes script, "powershell"
  end

  def test_run_alias_still_dispatches
    stdout, stderr, status = gob("help", "run")
    assert status.success?, stderr
    assert_match(/gob run FILE \[ARGS\.\.\.\]/, stdout)
  end

  private

    def completion(shell)
      stdout, stderr, status = gob("completion", "--shell", shell)
      assert status.success?, stderr
      assert_empty stderr
      stdout
    end

    def gob(*arguments)
      Open3.capture3(RbConfig.ruby, "-I", LIB, EXECUTABLE, *arguments)
    end
end
