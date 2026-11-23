# frozen_string_literal: true

require "json"

module SyntaxTree
  module Go
    module Materializer
      RUBY_KEYWORDS = %w[
        __FILE__ __LINE__ alias and begin BEGIN break case class def defined?
        do else elsif end END ensure false for if in module next nil not or
        redo rescue retry return self super then true undef unless until when
        while yield
      ].to_set

      SCHEMA_PATH = ::File.expand_path("schema.json", __dir__)

      class << self
        def schema
          @schema ||= JSON.parse(::File.read(SCHEMA_PATH))
        end

        def schema_by_name
          @schema_by_name ||= schema.to_h { |n| [n["name"], n] }
        end

        def snake(name)
          name.gsub(/([a-z0-9])([A-Z])/, "\\1_\\2").downcase
        end

        def fname(field_name)
          name = snake(field_name)
          RUBY_KEYWORDS.include?(name) ? "#{name}_" : name
        end

        def materialize(value)
          case value
          when Array
            value.map { |v| materialize(v) }
          when Hash
            if value["type"] && value["fields"]
              materialize_node(value)
            else
              value
            end
          else
            value
          end
        end

        def materialize_node(hash)
          type = hash["type"]
          fields = hash["fields"] || {}
          node_def = schema_by_name[type]
          klass = SyntaxTree::Go.const_get(type)

          unless node_def
            # Unknown node type; best-effort pass-through
            return klass.new
          end

          kwargs = {}
          node_def["fields"].each do |f|
            key = fname(f["name"]).to_sym
            raw = fields.key?(f["name"]) ? fields[f["name"]] : nil
            kwargs[key] = convert_field(f, raw)
          end

          kwargs[:location] = SyntaxTree::Location.default
          kwargs[:comments] = [] unless kwargs.key?(:comments)

          klass.new(**kwargs)
        end

        def convert_field(field, raw)
          role = field["role"]
          case role
          when "child"
            raw.nil? ? nil : materialize(raw)
          when "children"
            raw.is_a?(Array) ? raw.map { |v| materialize(v) } : []
          when "token"
            raw.nil? ? nil : raw.to_sym
          when "pos", "bool", "string", "scalar", "semantic", "map"
            raw
          else
            materialize(raw)
          end
        end
      end
    end
  end
end
