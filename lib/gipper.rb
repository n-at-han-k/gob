# frozen_string_literal: true

require "ffi"
require "json"

module Gipper
  extend FFI::Library

  LIB = File.expand_path("../ext/gipper/libgipper.#{FFI::Platform::LIBSUFFIX}", __dir__)
  ffi_lib LIB

  attach_function :ParseFileJSON, [:string, :string], :pointer
  attach_function :FreeString, [:pointer], :void

  def self.parse_file(source, filename: "main.go")
    ptr = ParseFileJSON(filename, source)
    raise "Gipper.ParseFileJSON returned null" if ptr.null?

    json = ptr.read_string.force_encoding("UTF-8")
    JSON.parse(json)
  ensure
    FreeString(ptr) if ptr && !ptr.null?
  end
end
