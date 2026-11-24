# frozen_string_literal: true

require "ffi"
require "json"

module GoFormatter
  class Error < StandardError; end

  extend FFI::Library # rubocop:disable Layout/EmptyLinesAfterModuleInclusion, Transpile/BlankLineBetweenStatements
  ffi_lib File.expand_path("../ext/goformatter/libgoformatter.#{FFI::Platform::LIBSUFFIX}", __dir__)
  attach_function :FormatSourceJSON, [:string], :pointer
  attach_function :FreeString, [:pointer], :void

  def self.format(source)
    pointer = FormatSourceJSON(source)

    if pointer.null?
      raise Error, "GoFormatter.FormatSourceJSON returned null"
    end

    result = JSON.parse(pointer.read_string.force_encoding("UTF-8"))

    if result["error"]
      raise Error, result.fetch("error")
    end

    result.fetch("output")
  ensure
    if pointer && !pointer.null?
      FreeString(pointer)
    end
  end
end
