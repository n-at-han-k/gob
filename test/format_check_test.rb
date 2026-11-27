# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "gob/validation/rules"
require "minitest/autorun"
require "minitest/reporters"

# The cases in test/cases are written in house style, so the cops must have
# nothing to say about them. A reported offence or a rewritten line here is a
# cop misreading correct Gob, not a case that needs fixing.
class FormatCheckTest < Minitest::Test
  CASES = Dir[File.expand_path("cases/**/*.gob", __dir__)].sort.freeze

  def test_cases_exist
    refute_empty CASES, "No .gob cases found under test/cases"
  end

  CASES.each do |path|
    relative = path.delete_prefix("#{File.expand_path("..", __dir__)}/")

    define_method("test_#{relative.tr("/.", "__")}_is_clean") do
      source = File.read(path)
      offences = Gob::Validation::Rules.validate(source, path: path)

      assert_empty(
        offences.map { |offence| "#{relative}:#{offence.line}:#{offence.column}: #{offence.cop_name}: #{offence.message}" },
        "Cops reported offences against house-style Gob"
      )

      assert_equal(
        source,
        Gob::Validation::Rules.autocorrect(source, path: path),
        "`gob fmt` rewrote house-style Gob in #{relative}"
      )
    end
  end
end
