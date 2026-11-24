# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "go_formatter"
require "minitest/autorun"

class GoFormatterTest < Minitest::Test
  def test_formats_go_source
    source = "package main;func main(){println(1)}"
    expected = "package main\n\nfunc main() { println(1) }\n"
    assert_equal expected, GoFormatter.format(source)
  end

  def test_reports_invalid_source
    error = assert_raises(GoFormatter::Error) { GoFormatter.format("package main\nfunc main( {\n") }
    assert_match(/expected/, error.message)
  end
end
