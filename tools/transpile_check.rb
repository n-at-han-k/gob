#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "gob"
require "syntax_tree/go"
require "json"
require "optparse"
require "pathname"
require "fileutils"

options = { limit: nil, verbose: false, write: true, root: "test/cases/standard-lib-examples" }

OptionParser.new do |opts|
  opts.banner = "Usage: tools/transpile_check.rb [options] [gob_file go_file]"
  opts.on("--root DIR", "Cases root (default: test/cases/standard-lib-examples)") { |v| options[:root] = v }
  opts.on("--limit N", Integer, "Limit number of files") { |v| options[:limit] = v }
  opts.on("--no-write", "Do not write .gob.out files") { options[:write] = false }
  opts.on("-v", "--verbose", "Show diff details") { options[:verbose] = true }
end.parse!(ARGV)

def pos_hash?(value)
  value.is_a?(Hash) && value.keys.sort == %w[column line offset]
end


def normalize_go_string(v)
  if v.start_with?("`") && v.end_with?("`")
    return v[1..-2]
  end
  if v.start_with?('"') && v.end_with?('"')
    inner = v[1..-2]
    # basic unescape for comparison
    return inner.gsub(/\\([abfnrtv\\'""])/) { |m|
      case m[1]
      when "a" then "\a"
      when "b" then "\b"
      when "f" then "\f"
      when "n" then "\n"
      when "r" then "\r"
      when "t" then "\t"
      when "v" then "\v"
      when "\\\\" then "\\\\"
      when '"' then '"'
      when "'" then "'"
      else m
      end
    }
  end
  v
end
def normalize(node)
  case node
  when SyntaxTree::Go::Node
    if node.is_a?(SyntaxTree::Go::ParenExpr)
      return normalize(node.x)
    end
    # normalize: simple var decl -> := assign for comparison
    if node.is_a?(SyntaxTree::Go::DeclStmt) && node.decl.is_a?(SyntaxTree::Go::GenDecl) && node.decl.tok.to_s == "var" && node.decl.specs.length == 1
      spec = node.decl.specs.first
      if spec.names.length >= 1 && spec.values && spec.values.length == spec.names.length && spec.type.nil?
        assign = SyntaxTree::Go::AssignStmt.new(lhs: spec.names, tok: ":=", rhs: spec.values)
        return normalize(assign)
      end
    end
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
      next if key == :doc
      next if key.to_s.end_with?("_pos")
      next if key.to_s.end_with?("_end")
      next if %i[opening closing lparen rparen lbrace rbrace lbrack rbrack colon semicolon arrow ellipsis tok_pos begin_ end_ pos func return_ case_ for_ if_ else_ defer go select range struct interface map chan switch star].include?(key)
      next if pos_hash?(value)

      hash[key.to_s] = normalize(value)
    end
    if hash["type"] == "BasicLit" && hash["kind"] == "INT" && hash["value"].is_a?(String)
      v = hash["value"].delete("_")
      begin
        hash["value"] = Integer(v).to_s
      rescue ArgumentError
        hash["value"] = v
      end
    end
    if hash["type"] == "BasicLit" && hash["kind"] == "FLOAT" && hash["value"].is_a?(String)
      v = hash["value"].delete("_")
      begin
        hash["value"] = Float(v).to_s
      rescue ArgumentError
        hash["value"] = v
      end
    end
    if hash["type"] == "BasicLit" && hash["kind"] == "STRING" && hash["value"].is_a?(String)
      hash["value"] = normalize_go_string(hash["value"])
    end
    hash
  when Array
    node.map { |v| normalize(v) }
  when Hash
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

pairs = []
if ARGV.length == 2
  pairs << [ARGV[0], ARGV[1]]
else
  root = Pathname(options[:root])
  Dir[root.join("**/*.gob").to_s].sort.each do |gob|
    go = gob.sub(/\.gob\z/, ".go")
    pairs << [gob, go] if File.exist?(go)
  end
end
pairs = pairs.first(options[:limit]) if options[:limit]

ok = diff = err = 0
pairs.each do |gob, go|
  begin
    src = File.read(gob)
    actual_ast = Gob.transpile(src, path: gob)
    actual_go = Gob::Go::Printer.print(actual_ast)
    if options[:write]
      File.write("#{gob}.out", actual_go)
    end

    expected_ast = SyntaxTree::Go.parse(File.read(go))
    na = normalize(actual_ast)
    ne = normalize(expected_ast)
    if na == ne
      ok += 1
      puts "OK #{gob}" if options[:verbose]
    else
      diff += 1
      puts "DIFF #{gob}"
      if options[:verbose]
        compare(ne, na).each { |d| puts "  #{d}" }
      end
    end
  rescue => e
    err += 1
    puts "ERR #{gob}"
    puts "  #{e.class}: #{e.message}"
    if options[:verbose]
      puts e.backtrace.first(5).map { |l| "  #{l}" }
    end
    if options[:write]
      begin
        # still try to write partial/errored output? skip
      rescue
      end
    end
  end
end

puts "ok=#{ok} diff=#{diff} err=#{err} total=#{pairs.length}"
