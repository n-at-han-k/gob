# frozen_string_literal: true

require_relative "support/syntax_test"
require "gob/transpilation/runner"

class SignatureCommentTest < SyntaxTest
  def parse(text)
    obj = Object.new
    obj.extend(Gob::Transpilation::Runner::DefinitionNodes)
    obj.parse_signature_comment(text)
  end

  def test_empty_signature
    assert_equal({ params: [], returns: [] }, parse("# "))
  end

  def test_no_params_no_return
    assert_equal({ params: [], returns: [] }, parse("# ()"))
  end

  def test_params_only_outer_parens
    assert_equal({ params: ["int", "string"], returns: [] }, parse("# (int, string)"))
  end

  def test_single_return
    assert_equal({ params: ["int", "int"], returns: [{ name: nil, type: "int" }] }, parse("# (int, int) -> int"))
  end

  def test_multiple_returns
    assert_equal(
      { params: ["[]byte"], returns: [{ name: nil, type: "int" }, { name: nil, type: "error" }] },
      parse("# ([]byte) -> (int, error)")
    )
  end

  def test_named_return
    assert_equal(
      { params: ["string"], returns: [{ name: "n", type: "int" }, { name: "err", type: "error" }] },
      parse("# (string) -> (n int, err error)")
    )
  end

  def test_void_return_arrow_empty_parens
    assert_equal({ params: ["int"], returns: [] }, parse("# (int) -> ()"))
  end

  def test_func_typed_param_with_return
    assert_equal(
      { params: ["func(Event)"], returns: [{ name: nil, type: "error" }] },
      parse("# func(Event) -> error")
    )
  end

  def test_func_typed_param_void
    assert_equal(
      { params: ["context.Context", "string", "func(directory.Event)"], returns: [] },
      parse("# context.Context, string, func(directory.Event) -> ()")
    )
  end

  def test_func_param_with_multiple_args
    assert_equal(
      { params: ["func(int, string) bool"], returns: [] },
      parse("# func(int, string) bool -> ()")
    )
  end

  def test_variadic_param
    assert_equal(
      { params: ["[]byte", "...KSUID"], returns: [{ name: nil, type: "CompressedSet" }] },
      parse("# ([]byte, ...KSUID) -> CompressedSet")
    )
  end

  def test_pointer_and_slice_types
    assert_equal(
      { params: ["*http.Request", "error"], returns: [{ name: nil, type: "*http.Request" }, { name: nil, type: "interface{}" }] },
      parse("# (*http.Request, error) -> (*http.Request, interface{})")
    )
  end

  def test_generic_brackets
    assert_equal(
      { params: [], returns: [{ name: nil, type: "iter.Seq[int]" }] },
      parse("# () -> iter.Seq[int]")
    )
  end

  def test_no_outer_parens_form
    assert_equal(
      { params: ["int", "int"], returns: [{ name: nil, type: "int" }] },
      parse("# int, int -> int")
    )
  end

  def test_sig__chi_router_string_http_filesystem_
    assert_equal({params: ["chi.Router", "string", "http.FileSystem"], returns: []}, parse("# (chi.Router, string, http.FileSystem)"))
  end

  def test_sig__http_handler
    assert_equal({params: [], returns: [{name: nil, type: "http.Handler"}]}, parse("# -> http.Handler"))
  end

  def test_sig__chi_router_
    assert_equal({params: ["chi.Router"], returns: []}, parse("# (chi.Router)"))
  end

  def test_sig__string_string_http_handler_error
    assert_equal({params: ["string", "string", "http.Handler"], returns: [{name: nil, type: "error"}]}, parse("# (string, string, http.Handler) -> error"))
  end

  def test_sig__chi_router
    assert_equal({params: [], returns: [{name: nil, type: "chi.Router"}]}, parse("# -> chi.Router"))
  end

  def test_sig__string_func_http_handler_http_handler
    assert_equal({params: ["string"], returns: [{name: nil, type: "func(http.Handler) http.Handler"}]}, parse("# (string) -> func(http.Handler) http.Handler"))
  end

  def test_sig__http_handler_http_handler
    assert_equal({params: ["http.Handler"], returns: [{name: nil, type: "http.Handler"}]}, parse("# (http.Handler) -> http.Handler"))
  end

  def test_sig__data_article_article
    assert_equal({params: ["*data.Article"], returns: [{name: nil, type: "*Article"}]}, parse("# (*data.Article) -> *Article"))
  end

  def test_sig__chan_bool_
    assert_equal({params: ["chan bool"], returns: []}, parse("# (chan bool)"))
  end

  def test_sig__func_int
    assert_equal({params: [], returns: [{name: nil, type: "func() int"}]}, parse("# -> func() int"))
  end

  def test_sig__string_os_file
    assert_equal({params: ["string"], returns: [{name: nil, type: "*os.File"}]}, parse("# (string) -> *os.File"))
  end

  def test_sig__os_file_
    assert_equal({params: ["*os.File"], returns: []}, parse("# (*os.File)"))
  end

  def test_sig__error_
    assert_equal({params: ["error"], returns: []}, parse("# (error)"))
  end

  def test_sig__string_
    assert_equal({params: ["string"], returns: []}, parse("# (string)"))
  end

  def test_sig__string_fs_direntry_error_error
    assert_equal({params: ["string", "fs.DirEntry", "error"], returns: [{name: nil, type: "error"}]}, parse("# (string, fs.DirEntry, error) -> error"))
  end

  def test_sig__int_error
    assert_equal({params: ["int"], returns: [{name: nil, type: "error"}]}, parse("# (int) -> error"))
  end

  def test_sig__int_int_int_int
    assert_equal({params: ["int", "int", "int"], returns: [{name: nil, type: "int"}]}, parse("# (int, int, int) -> int"))
  end

  def test_sig__int
    assert_equal({params: [], returns: [{name: nil, type: "int"}]}, parse("# -> int"))
  end

  def test_sig__int_int_
    assert_equal({params: [], returns: [{name: nil, type: "int"}, {name: nil, type: "int"}]}, parse("# -> (int, int)"))
  end

  def test_sig__int_
    assert_equal({params: ["int"], returns: []}, parse("# (int)"))
  end

  def test_sig__int_
    assert_equal({params: ["*int"], returns: []}, parse("# (*int)"))
  end

  def test_sig__rune_
    assert_equal({params: ["rune"], returns: []}, parse("# (rune)"))
  end

  def test_sig__string_person
    assert_equal({params: ["string"], returns: [{name: nil, type: "*person"}]}, parse("# (string) -> *person"))
  end

  def test_sig__net_conn_
    assert_equal({params: ["net.Conn"], returns: []}, parse("# (net.Conn)"))
  end

  def test_sig__int_chan_int_chan_int_
    assert_equal({params: ["int", "<-chan int", "chan<- int"], returns: []}, parse("# (int, <-chan int, chan<- int)"))
  end

  def test_sig__byte_byte
    assert_equal({params: ["byte"], returns: [{name: nil, type: "byte"}]}, parse("# (byte) -> byte"))
  end

  def test_sig__ksuid_ksuid_
    assert_equal({params: ["ksuid.KSUID"], returns: []}, parse("# (ksuid.KSUID)"))
  end

  def test_sig__byte_byte
    assert_equal({params: ["[]byte"], returns: [{name: nil, type: "[]byte"}]}, parse("# ([]byte) -> []byte"))
  end

  def test_sig__string_error
    assert_equal({params: ["string"], returns: [{name: nil, type: "error"}]}, parse("# (string) -> error"))
  end

  def test_sig__byte_error_
    assert_equal({params: [], returns: [{name: nil, type: "[]byte"}, {name: nil, type: "error"}]}, parse("# () -> ([]byte, error)"))
  end

  def test_sig__byte_error
    assert_equal({params: ["[]byte"], returns: [{name: nil, type: "error"}]}, parse("# ([]byte) -> error"))
  end

  def test_sig__driver_value_error_
    assert_equal({params: [], returns: [{name: nil, type: "driver.Value"}, {name: nil, type: "error"}]}, parse("# () -> (driver.Value, error)"))
  end

  def test_sig__interface_error
    assert_equal({params: ["interface{}"], returns: [{name: nil, type: "error"}]}, parse("# (interface{}) -> error"))
  end

  def test_sig__string_ksuid
    assert_equal({params: ["string"], returns: [{name: nil, type: "KSUID"}]}, parse("# (string) -> KSUID"))
  end

  def test_sig__time_time_uint32
    assert_equal({params: ["time.Time"], returns: [{name: nil, type: "uint32"}]}, parse("# (time.Time) -> uint32"))
  end

  def test_sig__uint32_time_time
    assert_equal({params: ["uint32"], returns: [{name: nil, type: "time.Time"}]}, parse("# (uint32) -> time.Time"))
  end

  def test_sig__ksuid_ksuid_err_error_
    assert_equal({params: [], returns: [{name: "ksuid", type: "KSUID"}, {name: "err", type: "error"}]}, parse("# () -> (ksuid KSUID, err error)"))
  end

  def test_sig__byte_ksuid
    assert_equal({params: ["[]byte"], returns: [{name: nil, type: "KSUID"}]}, parse("# ([]byte) -> KSUID"))
  end

  def test_sig__io_reader_
    assert_equal({params: ["io.Reader"], returns: []}, parse("# (io.Reader)"))
  end

  def test_sig__ksuid_
    assert_equal({params: ["[]KSUID"], returns: []}, parse("# ([]KSUID)"))
  end

  def test_sig__ksuid_bool
    assert_equal({params: ["[]KSUID"], returns: [{name: nil, type: "bool"}]}, parse("# ([]KSUID) -> bool"))
  end

  def test_sig__ksuid_int_int_
    assert_equal({params: ["[]KSUID", "int", "int"], returns: []}, parse("# ([]KSUID, int, int)"))
  end

  def test_sig__r_io_reader_err_error_
    assert_equal({params: [], returns: [{name: "r", type: "io.Reader"}, {name: "err", type: "error"}]}, parse("# () -> (r io.Reader, err error)"))
  end

  def test_sig__seed_int64_err_error_
    assert_equal({params: [], returns: [{name: "seed", type: "int64"}, {name: "err", type: "error"}]}, parse("# () -> (seed int64, err error)"))
  end

  def test_sig__ksuid_error_
    assert_equal({params: [], returns: [{name: nil, type: "KSUID"}, {name: nil, type: "error"}]}, parse("# () -> (KSUID, error)"))
  end

  def test_sig__min_ksuid_max_ksuid_
    assert_equal({params: [], returns: [{name: "min", type: "KSUID"}, {name: "max", type: "KSUID"}]}, parse("# () -> (min KSUID, max KSUID)"))
  end

  def test_sig__bytes_buffer_
    assert_equal({params: ["*bytes.Buffer"], returns: []}, parse("# (*bytes.Buffer)"))
  end

  def test_sig__ksuid_compressedset
    assert_equal({params: ["...KSUID"], returns: [{name: nil, type: "CompressedSet"}]}, parse("# (...KSUID) -> CompressedSet"))
  end

  def test_sig__ksuid_uint32_ksuid_uint128_length_int_count_int_
    assert_equal({params: ["[]KSUID", "uint32", "KSUID", "uint128"], returns: [{name: "length", type: "int"}, {name: "count", type: "int"}]}, parse("# ([]KSUID, uint32, KSUID, uint128) -> (length int, count int)"))
  end

  def test_sig__byte_uint128_int_byte
    assert_equal({params: ["[]byte", "uint128", "int"], returns: [{name: nil, type: "[]byte"}]}, parse("# ([]byte, uint128, int) -> []byte"))
  end

  def test_sig__byte_uint64_int_byte
    assert_equal({params: ["[]byte", "uint64", "int"], returns: [{name: nil, type: "[]byte"}]}, parse("# ([]byte, uint64, int) -> []byte"))
  end

  def test_sig__byte_uint32_int_byte
    assert_equal({params: ["[]byte", "uint32", "int"], returns: [{name: nil, type: "[]byte"}]}, parse("# ([]byte, uint32, int) -> []byte"))
  end

  def test_sig__byte_uint128
    assert_equal({params: ["[]byte"], returns: [{name: nil, type: "uint128"}]}, parse("# ([]byte) -> uint128"))
  end

  def test_sig__byte_uint64
    assert_equal({params: ["[]byte"], returns: [{name: nil, type: "uint64"}]}, parse("# ([]byte) -> uint64"))
  end

  def test_sig__byte_uint32
    assert_equal({params: ["[]byte"], returns: [{name: nil, type: "uint32"}]}, parse("# ([]byte) -> uint32"))
  end

  def test_sig__uint128_int
    assert_equal({params: ["uint128"], returns: [{name: nil, type: "int"}]}, parse("# (uint128) -> int"))
  end

  def test_sig__uint64_int
    assert_equal({params: ["uint64"], returns: [{name: nil, type: "int"}]}, parse("# (uint64) -> int"))
  end

  def test_sig__uint32_int
    assert_equal({params: ["uint32"], returns: [{name: nil, type: "int"}]}, parse("# (uint32) -> int"))
  end

  def test_sig__ksuid_uint128
    assert_equal({params: ["KSUID"], returns: [{name: nil, type: "uint128"}]}, parse("# (KSUID) -> uint128"))
  end

  def test_sig__uint32_out_ksuid_
    assert_equal({params: ["uint32"], returns: [{name: "out", type: "KSUID"}]}, parse("# (uint32) -> (out KSUID)"))
  end

  def test_sig__out_16_byte_
    assert_equal({params: [], returns: [{name: "out", type: "[16]byte"}]}, parse("# () -> (out [16]byte)"))
  end

  def test_sig__uint128_uint128_z_uint128_
    assert_equal({params: ["uint128", "uint128"], returns: [{name: "z", type: "uint128"}]}, parse("# (uint128, uint128) -> (z uint128)"))
  end

  def test_sig__uint128_z_uint128_
    assert_equal({params: ["uint128"], returns: [{name: "z", type: "uint128"}]}, parse("# (uint128) -> (z uint128)"))
  end

  def test_sig__string_string_
    assert_equal({params: [], returns: [{name: nil, type: "string"}, {name: nil, type: "string"}]}, parse("# -> (string, string)"))
  end

  def test_sig__byte_
    assert_equal({params: ["[]byte"], returns: []}, parse("# ([]byte)"))
  end

  def test_sig__any_
    assert_equal({params: ["any"], returns: []}, parse("# (any)"))
  end

  def test_sig__context_context_error
    assert_equal({params: ["context.Context"], returns: [{name: nil, type: "error"}]}, parse("# (context.Context) -> error"))
  end

  def test_sig__expvar_keyvalue_
    assert_equal({params: ["expvar.KeyValue"], returns: []}, parse("# (expvar.KeyValue)"))
  end

  def test_sig__ast_node_bool
    assert_equal({params: ["ast.Node"], returns: [{name: nil, type: "bool"}]}, parse("# (ast.Node) -> bool"))
  end

  def test_sig__os_file_error
    assert_equal({params: ["*os.File"], returns: [{name: nil, type: "error"}]}, parse("# (*os.File) -> error"))
  end

  def test_sig__int_image_rgba
    assert_equal({params: ["int"], returns: [{name: nil, type: "*image.RGBA"}]}, parse("# (int) -> *image.RGBA"))
  end

  def test_sig__string_func_os_file_error_
    assert_equal({params: ["string", "func(*os.File) error"], returns: []}, parse("# string, func(*os.File) error -> ()"))
  end

  def test_sig__image_image_byte
    assert_equal({params: ["image.Image"], returns: [{name: nil, type: "[]byte"}]}, parse("# (image.Image) -> []byte"))
  end

  def test_sig__int_iter_seq_int_
    assert_equal({params: ["int"], returns: [{name: nil, type: "iter.Seq[int]"}]}, parse("# (int) -> iter.Seq[int]"))
  end

  def test_sig__int_bool
    assert_equal({params: ["int"], returns: [{name: nil, type: "bool"}]}, parse("# (int) -> bool"))
  end

  def test_sig__byte_error_
    assert_equal({params: [], returns: [{name: nil, type: "[]byte"}, {name: nil, type: "error"}]}, parse("# -> ([]byte, error)"))
  end

  def test_sig__string_bool
    assert_equal({params: ["string"], returns: [{name: nil, type: "bool"}]}, parse("# string -> bool"))
  end

  def test_sig__string_url_url
    assert_equal({params: ["string"], returns: [{name: nil, type: "*url.URL"}]}, parse("# (string) -> *url.URL"))
  end

  def test_sig__httptrace_gotconninfo_
    assert_equal({params: ["httptrace.GotConnInfo"], returns: []}, parse("# (httptrace.GotConnInfo)"))
  end
end
