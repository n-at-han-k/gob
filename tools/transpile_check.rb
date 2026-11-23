#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "gob"
require "syntax_tree/go"
require "json"
require "optparse"

options = { limit: nil, verbose: false }

OptionParser.new do |opts|
  opts.banner = "Usage: tools/transpile_check.rb [options] [ruby_file go_file]"
  opts.on("--src DIR", "Ruby source dir (default: src)") { |v| options[:src] = v }
  opts.on("--out DIR", "Go golden dir (default: out)") { |v| options[:out] = v }
  opts.on("--limit N", Integer, "Limit number of files") { |v| options[:limit] = v }
  opts.on("-v", "--verbose", "Show diff details") { options[:verbose] = true }
end.parse!(ARGV)

def pos_hash?(value)
  value.is_a?(Hash) && value.keys.sort == %w[column line offset]
end

def normalize(node)
  case node
  when SyntaxTree::Go::Node
    hash = { "type" => node.class.name.split("::").last }
    node.deconstruct_keys(nil).each do |key, value|
      next if key == :location
      next if key == :comments
      next if key == :obj
      next if key == :scope
      next if key == :unresolved
      next if key == :file_start
      next if key == :file_end
      next if key == :package
      next if key == :go_version
      next if key.to_s.end_with?("_pos")
      next if key.to_s.end_with?("_end")
      next if %i[opening closing lparen rparen lbrace rbrace lbrack rbrack colon semicolon arrow ellipsis tok_pos begin_ end_ pos func return_ case_ for_ if_ else_].include?(key)
      next if pos_hash?(value)

      hash[key.to_s] = normalize(value)
    end
    hash
  when Array
    node.map { |v| normalize(v) }
  when Hash
    # pos hash or other metadata
    node
  when Symbol
    node.to_s
  else
    node
  end
end

def compare(expected, actual, path = "$", diffs = [], limit: 30)
  return diffs if diffs.length >= limit

  if expected.class != actual.class
    diffs << "#{path}: type #{expected.class} != #{actual.class}"
    return diffs
  end

  case expected
  when Hash
    keys = (expected.keys | actual.keys).sort
    keys.each do |k|
      break if diffs.length >= limit
      if !expected.key?(k)
        diffs << "#{path}.#{k}: missing in expected, got #{actual[k].inspect[0, 80]}"
      elsif !actual.key?(k)
        diffs << "#{path}.#{k}: missing in actual, expected #{expected[k].inspect[0, 80]}"
      else
        compare(expected[k], actual[k], "#{path}.#{k}", diffs, limit: limit)
      end
    end
  when Array
    if expected.length != actual.length
      diffs << "#{path}: length #{expected.length} != #{actual.length}"
    end
    [expected.length, actual.length].max.times do |i|
      break if diffs.length >= limit
      if i >= expected.length
        diffs << "#{path}[#{i}]: extra in actual #{actual[i].inspect[0, 80]}"
      elsif i >= actual.length
        diffs << "#{path}[#{i}]: missing in actual, expected #{expected[i].inspect[0, 80]}"
      else
        compare(expected[i], actual[i], "#{path}[#{i}]", diffs, limit: limit)
      end
    end
  else
    diffs << "#{path}: #{expected.inspect} != #{actual.inspect}" if expected != actual
  end

  diffs
end

def check_pair(ruby_file, go_file, verbose: false)
  ruby_source = ::File.read(ruby_file)
  go_source = ::File.read(go_file)

  begin
    actual_ast = Gob.transpile(ruby_source)
  rescue => e
    return { file: ruby_file, status: :transpile_error, error: "#{e.class}: #{e.message}" }
  end

  expected_ast = SyntaxTree::Go.parse(go_source)

  expected = normalize(expected_ast)
  actual = normalize(actual_ast)
  diffs = compare(expected, actual, limit: verbose ? 50 : 10)

  if diffs.empty?
    { file: ruby_file, status: :ok }
  else
    { file: ruby_file, status: :mismatch, diffs: diffs }
  end
end

pairs = []

if ARGV.length == 2
  pairs << [ARGV[0], ARGV[1]]
else
  src_dir = options[:src] || "src"
  out_dir = options[:out] || "out"
  Dir.glob("#{src_dir}/**/*.rb").sort.each do |rb|
    go = rb.sub(/^#{Regexp.escape(src_dir)}\//, "#{out_dir}/").sub(/\.rb$/, ".go")
    pairs << [rb, go] if ::File.exist?(go)
  end
end

pairs = pairs.first(options[:limit]) if options[:limit]

results = { ok: 0, mismatch: 0, transpile_error: 0, missing: 0 }
pairs.each do |rb, go|
  unless ::File.exist?(go)
    puts "MISS  #{rb} (no #{go})"
    results[:missing] += 1
    next
  end

  result = check_pair(rb, go, verbose: options[:verbose])
  case result[:status]
  when :ok
    puts "OK    #{rb}"
    results[:ok] += 1
  when :mismatch
    puts "DIFF  #{rb}"
    result[:diffs].each { |d| puts "  - #{d}" }
    results[:mismatch] += 1
  when :transpile_error
    puts "ERR   #{rb}"
    puts "  #{result[:error]}"
    results[:transpile_error] += 1
  end
end

puts ""
puts "ok=#{results[:ok]} diff=#{results[:mismatch]} err=#{results[:transpile_error]} missing=#{results[:missing]} total=#{pairs.length}"
exit 1 unless results[:mismatch] == 0 && results[:transpile_error] == 0 && results[:missing] == 0
