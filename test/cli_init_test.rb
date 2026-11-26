# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "rbconfig"
require "tmpdir"
require_relative "../lib/gob/cli"

class CLIInitTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  LIB = File.join(ROOT, "lib")
  EXECUTABLE = File.join(ROOT, "exe/gob")

  GO = ["go"].find do |candidate|
    Open3.capture3(candidate, "version").last.success?
  rescue Errno::ENOENT
    false
  end
  def test_initialises_a_go_module
    skip "Go is required" unless GO

    Dir.mktmpdir do |directory|
      _stdout, stderr, status = gob(directory, "init", "example.com/demo")
      assert status.success?, stderr
      assert_match(/^module example\.com\/demo$/, File.read(File.join(directory, "go.mod")))
      refute File.exist?(File.join(directory, "main.gob"))
    end
  end

  def test_refuses_to_overwrite_an_existing_go_mod
    skip "Go is required" unless GO

    Dir.mktmpdir do |directory|
      go_mod = File.join(directory, "go.mod")
      File.write(go_mod, "module existing\n")
      _stdout, stderr, status = gob(directory, "init", "example.com/demo")
      refute status.success?
      assert_match(/go\.mod already exists/, stderr)
      assert_equal "module existing\n", File.read(go_mod)
    end
  end

  private

    def gob(directory, *arguments)
      Open3.capture3(RbConfig.ruby, "-I", LIB, EXECUTABLE, *arguments, chdir: directory)
    end
end
