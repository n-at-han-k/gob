#!/usr/bin/env ruby
#
# runner.rb
# Copyright (C) 2026 nathan <nathan@elitedesk>
#
# Distributed under terms of the MIT license.
#

module Gob
  module Transpilation
    class Runner
      module DefinitionNodes
        def parse_signature_comment(text)
          body = text.to_s.strip.sub(/\A#\s*/, "")
          parts = body.split(/\s*->\s*/, 2)
          left = parts[0].to_s.strip
          right = parts[1].to_s.strip

          split_items = ->(v) {
            v = v.strip
            case v
            in /\A\((?<inner>.*)\)\z/m then v = $~[:inner].strip
            else nil
            end

            case v
            in /\A\s*\z/ then []
            else
              v.scan(/func\([^()]*\)(?:\s+[^,]+)?|\[[^\[\]]*\][^,]*|[^,]+/).map(&:strip).reject(&:empty?)
            end
          }

          {
            params: split_items.call(left),
            returns: split_items.call(right).map { |item|
              case item
              in /\A([A-Za-z_]\w*)\s+(.+)\z/ if !%w[chan func map interface struct].include?($1)
                { name: $1, type: $2 }
              else
                { name: nil, type: item }
              end
            }
          }
        end


        # var colour = Struct.new(R: byte)
        # type colour struct { R byte }
        # ---
        def TypeDecl(name, fields)
          SyntaxTree::Go::GenDecl.new(
            tok: :type,
            specs: [
              SyntaxTree::Go::TypeSpec.new(
                name: Ident(name),
                type: SyntaxTree::Go::StructType.new(
                  fields: SyntaxTree::Go::FieldList.new(list: fields)
                )
              )
            ]
          )
        end

        def TypeDefinition(name, type)
          SyntaxTree::Go::GenDecl.new(
            tok: :type,
            specs: [
              SyntaxTree::Go::TypeSpec.new(
                name: Ident(name),
                type: Statements(type)
              )
            ]
          )
        end

        # type :CompressedSet, Array[byte]
        # type CompressedSet []byte
        # ---
        def Alias(name, type)
          SyntaxTree::Go::GenDecl.new(
            tok: :type,
            specs: [ SyntaxTree::Go::TypeSpec.new(name: Ident(name), type: Statements(type)) ]
          )
        end

        # Title: string, # `json:"title"`
        # Title string `json:"title"`
        # ---
        def Fields(assocs)
          Array(assocs).filter_map do |assoc|
            case assoc
            in SyntaxTree::Assoc[
              key: SyntaxTree::Label[value: label],
              value: type,
              comments: [SyntaxTree::Comment[value: tag], *]
            ]
              SyntaxTree::Go::Field.new(
                names: [ Ident(label.delete_suffix(":")) ],
                type:  Statements(type),
                tag:   BasicLit(:STRING, tag.sub(/\A#\s*/, ""))
              )

            in SyntaxTree::Assoc[ key: SyntaxTree::Label[value: label], value: type ]
              SyntaxTree::Go::Field.new(
                names: [ Ident(label.delete_suffix(":")) ],
                type:  Statements(type)
              )

            # attr_accessor :A, int
            # A int
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "attr_accessor"],
              arguments: SyntaxTree::Args[ parts: [ { value: { value: label } }, type ] ]
            ]
              SyntaxTree::Go::Field.new(names: [ Ident(label) ], type: Statements(type))

            else
              nil
            end
          end
        end

        # A method takes a pointer receiver, because a method that cannot modify
        # its receiver is the exception rather than the rule. `protected` is that
        # exception: it hands the method a copy, so the instance is protected
        # from modification.
        #
        # def Mutate(value) # (int)
        # func (self *colour) Mutate(value int)
        # ---
        # protected def MarshalText # () -> ([]byte, error)
        # func (self colour) MarshalText() ([]byte, error)
        # ---
        def Methods(name, body)
          Array(body).filter_map do |node|
            case node
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "protected"],
              arguments: SyntaxTree::Args[ parts: [ SyntaxTree::DefNode => definition ] ]
            ]
              Method(definition, receiver: Receiver(name, pointer: false))

            in SyntaxTree::DefNode => definition
              Method(definition, receiver: Receiver(name, pointer: true))

            else
              nil
            end
          end
        end

        # self is the name Gob gives every receiver.
        # ---
        def Receiver(name, pointer:)
          type = Ident(name)

          SyntaxTree::Go::FieldList.new(
            list: [
              SyntaxTree::Go::Field.new(
                names: [ Ident("self") ],
                type:  pointer ? SyntaxTree::Go::StarExpr.new(x: type) : type
              )
            ]
          )
        end

        # Reads one definition, whatever shape its signature takes.
        # ---
        def Method(definition, receiver:)
          definition => SyntaxTree::DefNode[
            name: { value: method },
            params: params,
            bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[ body: statements ] ]
          ]

          descend(statements, declared: ["self", *Scope(params)]).then do |children|
            Function(name: method, params: params, body: children.tree, receiver: receiver)
          end
        end

        # The names a signature brings into scope: the parameters it binds and
        # the results it names.
        # ---
        def Scope(params)
          case params
          in { contents: SyntaxTree::Params[requireds: args], comments: [SyntaxTree::Comment[value: types], *] }
            [*args.map(&:value), *ResultNames(types)]

          in { contents: SyntaxTree::Params[requireds: args] }
            args.map(&:value)

          in { comments: [SyntaxTree::Comment[value: types], *] }
            ResultNames(types)

          else
            []
          end
        end

        def ResultNames(types)
          parse_signature_comment(types)[:returns].filter_map { |result| result[:name] }
        end

        def Function(name:, params:, body:, receiver: nil)
          sig =
            case params
            in { contents: SyntaxTree::Params, comments: [SyntaxTree::Comment[value: types], *] }
              parse_signature_comment(types)
            in { comments: [SyntaxTree::Comment[value: types], *] }
              parse_signature_comment(types)
            else
              { params: [], returns: [] }
            end

          case params
          in { contents: SyntaxTree::Params[requireds: args] }
            input = sig[:params].dup
            params = args.map { |arg|
              SyntaxTree::Go::Field.new(
                names: [SyntaxTree::Go::Ident.new(name: arg.value)],
                type: SyntaxTree::Go::Ident.new(name: input.shift)
              )
            }
          else
            params = []
          end

          results = sig[:returns].map do |ret|
            if ret[:name]
              SyntaxTree::Go::Field.new(names: [Ident(ret[:name])], type: Ident(ret[:type]))
            else
              SyntaxTree::Go::Field.new(type: Ident(ret[:type]))
            end
          end

          SyntaxTree::Go::FuncDecl.new(
            recv: receiver,
            name: SyntaxTree::Go::Ident.new(name: name),
            type: SyntaxTree::Go::FuncType.new(
              type_params: nil,
              params: SyntaxTree::Go::FieldList.new(list: params),
              results: SyntaxTree::Go::FieldList.new(list: results),
            ),
            body: SyntaxTree::Go::BlockStmt.new(list: body)
          )
        end
      end

      module LambdaNodes
        # lambda { |w, r| ... }
        # func(w http.ResponseWriter, r *http.Request) { ... }
        # ---
        def Lambda(block)
          case block
          in SyntaxTree::BlockNode[
            block_var: block_var,
            bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[ body: body ] ]
          ]
            FuncLit(block_var, body)

          in SyntaxTree::BlockNode[
            block_var: block_var,
            bodystmt: SyntaxTree::Statements[ body: body ]
          ]
            FuncLit(block_var, body)

          else
            nil
          end
        end

        # |tag| # string -> bool
        # (tag string) bool
        # ---
        def FuncLit(block_var, body)
          case block_var
          in SyntaxTree::BlockVar[
            params: SyntaxTree::Params[requireds: args],
            comments: [SyntaxTree::Comment[value: types], *]
          ]
            sig = parse_signature_comment(types)
          in SyntaxTree::BlockVar[ params: SyntaxTree::Params[requireds: args] ]
            sig = { params: [], returns: [] }
          else
            args = []
            sig = { params: [], returns: [] }
          end

          input = sig[:params].dup
          param_names = args.map(&:value)
          return_names = sig[:returns].filter_map { |ret| ret[:name] }

          SyntaxTree::Go::FuncLit.new(
            type: SyntaxTree::Go::FuncType.new(
              type_params: nil,
              params: SyntaxTree::Go::FieldList.new(
                list: args.map { |arg|
                  SyntaxTree::Go::Field.new(names: [Ident(arg.value)], type: Ident(input.shift))
                }
              ),
              results: SyntaxTree::Go::FieldList.new(
                list: sig[:returns].map { |ret|
                  ret[:name] ? SyntaxTree::Go::Field.new(names: [Ident(ret[:name])], type: Ident(ret[:type])) : SyntaxTree::Go::Field.new(type: Ident(ret[:type]))
                }
              )
            ),
            body: descend(body, declared: [*param_names, *return_names]).then { |children| Block(body: children.tree) }
          )
        end
      end

      module BlockNodes
        def Block(body:)
          SyntaxTree::Go::BlockStmt.new(list: body)
        end
      end

      module LogicNodes
        # if err != nil
        # if err
        # ---
        def Truthy(node)
          case node
          in SyntaxTree::Go::Ident[name: "err"]
            Binary(node, :!=, Ident(:nil))

          else
            node
          end
        end

        # unless err != nil
        # if err == nil
        # ---
        def Not(node)
          case node
          in SyntaxTree::Go::BinaryExpr[x: x, op: :!=, y: y]
            Binary(x, :==, y)

          in SyntaxTree::Go::BinaryExpr[x: x, op: :==, y: y]
            Binary(x, :!=, y)

          else
            SyntaxTree::Go::UnaryExpr.new(op: :!, x: node)
          end
        end

        # if err = f()
        # if err := f(); err != nil
        # ---
        def Guard(node)
          case node
          in SyntaxTree::Paren[contents: SyntaxTree::Statements[body: [statement]]]
            Guard(statement)

          # if avail = c - n && avail < nbytes
          # if avail := c - n; avail < nbytes { ... }
          # ---
          in SyntaxTree::Assign[target: target, value: SyntaxTree::Binary[left: left, operator: :"&&", right: right], location: location]
            init, _, init_names = Guard(SyntaxTree::Assign.new(target: target, value: left, location: location))
            [init, Truthy(LeftHand(right)), init_names]

          in SyntaxTree::Assign[target: target, value: value]
            lhs = Array(LeftHand(target))
            names = lhs.grep(SyntaxTree::Go::Ident).map(&:name) - ["_"]
            init_names = undeclared(names)
            init = SyntaxTree::Go::AssignStmt.new(
              lhs: lhs,
              tok_pos: nil,
              tok: init_names.any? ? ":=" : "=",
              rhs: Array(RightHand(value))
            )
            [init, Truthy(init.lhs.last), init_names]

          in SyntaxTree::MAssign[target: target, value: value]
            lhs = Array(LeftHand(target))
            names = lhs.grep(SyntaxTree::Go::Ident).map(&:name) - ["_"]
            init_names = undeclared(names)
            init = SyntaxTree::Go::AssignStmt.new(
              lhs: lhs,
              tok_pos: nil,
              tok: init_names.any? ? ":=" : "=",
              rhs: Array(RightHand(value))
            )
            [init, Truthy(init.lhs.last), init_names]

          else
            [nil, Truthy(LeftHand(node)), []]
          end
        end

        def Body(ctx, statements, declared: [])
          ctx.descend(statements.body, declared: declared).then { |children| Block(body: children.tree) }
        end

        # if cond ... end
        # if cond { ... }
        # ---
        def If(ctx, predicate, statements, consequent, declared: [])
          init, cond, init_names = Guard(predicate)
          scope = [*declared, *init_names]

          SyntaxTree::Go::IfStmt.new(
            init:  init,
            cond:  cond,
            body:  Body(ctx, statements, declared: scope),
            else_: Logic(ctx, consequent, declared: scope)
          )
        end

        # unless cond ... end
        # if !cond { ... }
        # ---
        def Unless(ctx, predicate, statements, consequent, declared: [])
          init, cond, init_names = Guard(predicate)
          scope = [*declared, *init_names]

          SyntaxTree::Go::IfStmt.new(
            init:  init,
            cond:  Not(cond),
            body:  Body(ctx, statements, declared: scope),
            else_: Logic(ctx, consequent, declared: scope)
          )
        end

        # while cond ... end
        # for cond { ... }
        # ---
        def While(ctx, predicate, statements)
          init, cond, init_names = Guard(predicate)

          SyntaxTree::Go::ForStmt.new(
            init: init,
            cond: cond,
            post: nil,
            body: Body(ctx, statements, declared: init_names)
          )
        end

        # until cond ... end
        # for !cond { ... }
        # ---
        def Until(ctx, predicate, statements)
          init, cond, init_names = Guard(predicate)

          SyntaxTree::Go::ForStmt.new(
            init: init,
            cond: Not(cond),
            post: nil,
            body: Body(ctx, statements, declared: init_names)
          )
        end

        # loop do ... end
        # for { ... }
        # ---
        def Loop(ctx, statements)
          SyntaxTree::Go::ForStmt.new(
            init: nil,
            cond: nil,
            post: nil,
            body: Body(ctx, statements)
          )
        end

        # collection.each do |key, value| ... end
        # for key, value := range collection { ... }
        # ---
        # when metrics.KindUint64
        # case metrics.KindUint64:
        # ---
        def Cases(ctx, node)
          case node
          in SyntaxTree::When[
            arguments: SyntaxTree::Args[ parts: parts ],
            statements: SyntaxTree::Statements[ body: body ],
            consequent: consequent
          ]
            before = ctx.state.fetch(:declared).dup
            list = parts.map { |part| Statements(part) }
            declared = ctx.state.fetch(:declared) - before
            ctx.state.fetch(:declared).replace(before)
            [
              SyntaxTree::Go::CaseClause.new(
                list: list,
                body: ctx.descend(body, declared: declared).then { |children| children.tree }
              ),
              *Cases(ctx, consequent)
            ]

          # else
          # default:
          # ---
          in SyntaxTree::Else[ statements: SyntaxTree::Statements[ body: body ] ]
            [
              SyntaxTree::Go::CaseClause.new(
                list: [],
                body: ctx.descend(body).then { |children| children.tree }
              )
            ]

          else
            []
          end
        end

        # when msg = ~fast
        # case msg := <-fast:
        # ---
        def Comm(node)
          case node
          # when ch << "ping"
          # case ch <- "ping":
          # ---
          in SyntaxTree::Binary[ left: left, operator: :<<, right: right ]
            SyntaxTree::Go::SendStmt.new(chan: Statements(left), value: Statements(right))

          in SyntaxTree::Assign | SyntaxTree::MAssign
            Statements(node)

          else
            SyntaxTree::Go::ExprStmt.new(x: Statements(node))
          end
        end

        def Comms(ctx, node)
          case node
          in SyntaxTree::When[
            arguments: SyntaxTree::Args[ parts: [ comm ] ],
            statements: SyntaxTree::Statements[ body: body ],
            consequent: consequent
          ]
            before = ctx.state.fetch(:declared).dup
            comm_node = Comm(comm)
            declared = ctx.state.fetch(:declared) - before
            ctx.state.fetch(:declared).replace(before)
            [
              SyntaxTree::Go::CommClause.new(
                comm: comm_node,
                body: ctx.descend(body, declared: declared).then { |children| children.tree }
              ),
              *Comms(ctx, consequent)
            ]

          # else
          # default:
          # ---
          in SyntaxTree::Else[ statements: SyntaxTree::Statements[ body: body ] ]
            [
              SyntaxTree::Go::CommClause.new(
                comm: nil,
                body: ctx.descend(body).then { |children| children.tree }
              )
            ]

          else
            []
          end
        end

        # case ... end
        # select { ... }
        # ---
        def Select(ctx, consequent)
          SyntaxTree::Go::SelectStmt.new(
            body: SyntaxTree::Go::BlockStmt.new(list: Comms(ctx, consequent))
          )
        end

        # case s.Value.Kind() ... end
        # switch s.Value.Kind() { ... }
        # ---
        def Switch(ctx, value, consequent)
          SyntaxTree::Go::SwitchStmt.new(
            tag:  Statements(value),
            body: SyntaxTree::Go::BlockStmt.new(list: Cases(ctx, consequent))
          )
        end

        # case d = decl.(type) ... end
        # switch d := decl.(type) { ... }
        # ---
        def TypeSwitch(ctx, name, value, consequent)
          SyntaxTree::Go::TypeSwitchStmt.new(
            assign: SyntaxTree::Go::AssignStmt.new(
              lhs: [Ident(name)],
              tok: ":=",
              rhs: [SyntaxTree::Go::TypeAssertExpr.new(x: Statements(value), type: nil)]
            ),
            body: SyntaxTree::Go::BlockStmt.new(list: Cases(ctx, consequent))
          )
        end

        def Each(ctx, collection, requireds, statements)
          key, value = requireds.map { |required| Ident(required.value) }

          SyntaxTree::Go::RangeStmt.new(
            key:   key,
            value: value,
            tok:   ":=",
            x:     Statements(collection),
            body:  Body(ctx, statements)
          )
        end

        def Logic(ctx, node, declared: [])
          case node
          in SyntaxTree::IfNode[predicate: predicate, statements: statements, consequent: consequent]
            If(ctx, predicate, statements, consequent, declared: declared)

          in SyntaxTree::Elsif[predicate: predicate, statements: statements, consequent: consequent]
            If(ctx, predicate, statements, consequent, declared: declared)

          in SyntaxTree::UnlessNode[predicate: predicate, statements: statements, consequent: consequent]
            Unless(ctx, predicate, statements, consequent, declared: declared)

          in SyntaxTree::Else[statements: statements]
            Body(ctx, statements, declared: declared)

          in SyntaxTree::WhileNode[predicate: predicate, statements: statements]
            While(ctx, predicate, statements)

          in SyntaxTree::UntilNode[predicate: predicate, statements: statements]
            Until(ctx, predicate, statements)

          in SyntaxTree::MethodAddBlock[
            call: SyntaxTree::CallNode[
              message: SyntaxTree::Ident[value: "loop"]
            ],
            block: SyntaxTree::BlockNode[
              bodystmt: SyntaxTree::BodyStmt[statements: statements]
            ]
          ]
            Loop(ctx, statements)

          in SyntaxTree::MethodAddBlock[
            call: SyntaxTree::CallNode[
              receiver: collection,
              message: SyntaxTree::Ident[value: "each"]
            ],
            block: SyntaxTree::BlockNode[
              block_var: SyntaxTree::BlockVar[
                params: SyntaxTree::Params[requireds: requireds]
              ],
              bodystmt: SyntaxTree::BodyStmt[statements: statements]
            ]
          ]
            Each(ctx, collection, requireds, statements)

          # 3.times do |i| ... end
          # for i := range 3 { ... }
          # ---
          in SyntaxTree::MethodAddBlock[
            call: SyntaxTree::CallNode[
              receiver: count,
              message: SyntaxTree::Ident[value: "times"]
            ],
            block: SyntaxTree::BlockNode[
              block_var: SyntaxTree::BlockVar[
                params: SyntaxTree::Params[requireds: requireds]
              ],
              bodystmt: SyntaxTree::BodyStmt[statements: statements]
            ]
          ]
            Each(ctx, count, requireds, statements)

          # 100.times do ... end
          # for range 100 { ... }
          # ---
          in SyntaxTree::MethodAddBlock[
            call: SyntaxTree::CallNode[
              receiver: count,
              message: SyntaxTree::Ident[value: "times"]
            ],
            block: SyntaxTree::BlockNode[
              bodystmt: SyntaxTree::BodyStmt[statements: statements]
            ]
          ]
            Each(ctx, count, [], statements)

          # case ... end
          # select { ... }
          # ---
          in SyntaxTree::Case[ value: nil, consequent: consequent ]
            Select(ctx, consequent)

          # case d = decl.(type) ... end
          # switch d := decl.(type) { ... }
          # ---
          in SyntaxTree::Case[
            value: SyntaxTree::Assign[
              target: SyntaxTree::VarField[ value: { value: name } ],
              value: SyntaxTree::CallNode[
                receiver: receiver,
                message: :call,
                arguments: SyntaxTree::ArgParen[ arguments: SyntaxTree::Args[
                  parts: [ SyntaxTree::VCall[value: SyntaxTree::Ident[value: "type"]] ]
                ] ]
              ]
            ],
            consequent: consequent
          ]
            TypeSwitch(ctx, name, receiver, consequent)

          # case s.Value.Kind() ... end
          # switch s.Value.Kind() { ... }
          # ---
          in SyntaxTree::Case[ value: value, consequent: consequent ]
            Switch(ctx, value, consequent)

          else
            nil
          end
        end
      end

      module VariableNodes
        def Variable(node)
          case node
          in SyntaxTree::VarField[value: value]
            Variable(value)

          in SyntaxTree::VarRef[value: value]
            Variable(value)

          in SyntaxTree::VCall[value: value]
            Variable(value)

          in SyntaxTree::IVar[value: name]
            SyntaxTree::Go::UnaryExpr.new(
              op: :&,
              x: SyntaxTree::Go::Ident.new(name: name.delete_prefix("@"))
            )

          in SyntaxTree::CVar[value: name]
            SyntaxTree::Go::StarExpr.new(
              x: SyntaxTree::Go::Ident.new(name: name.delete_prefix("@@"))
            )

          # STATUS_ACTIVE
          # statusActive
          # ---
          in SyntaxTree::Const[value: name] if state.fetch(:uppercase_constants, []).include?(name)
            Constant(name)

          in { value: String => name }
            SyntaxTree::Go::Ident.new(name: name)

          else
            nil
          end
        end

        # STATUS_ACTIVE
        # statusActive
        # ---
        def Constant(name)
          head, *tail = name.downcase.split("_")

          Ident(head + tail.map(&:capitalize).join)
        end

        def Ident(name)             = SyntaxTree::Go::Ident.new(name: name.to_s)
        def BasicLit(kind, value)   = SyntaxTree::Go::BasicLit.new(kind: kind.to_sym, value: value.to_s)
        def CharLiteral(value)      = BasicLit(:CHAR, "'#{value}'")
        def StringLiteral(value)    = BasicLit(:STRING, "\"#{value}\"")
        def RawStringLiteral(value) = BasicLit(:STRING, "`#{value}`")
        def IntLiteral(value)       = BasicLit(:INT, value)
        def FloatLiteral(value)     = BasicLit(:FLOAT, value)

        def Receive(x)              = SyntaxTree::Go::UnaryExpr.new(op: :"<-", x: x)

        def Binary(left, operator, right, location: SyntaxTree::Location.default)
          SyntaxTree::Go::BinaryExpr.new(x: left, op: operator, y: right, location: location)
        end

        # append(b, *c)
        # append(b, c...)
        # ---
        def Arguments(parts)
          [
            Array(parts).map { |part|
              case part
              in SyntaxTree::ArgStar[value: value]
                Statements(value)
              else
                Statements(part)
              end
            },
            Array(parts).any? { |part| part.is_a?(SyntaxTree::ArgStar) }
          ]
        end

        def Call(node)
          case node

          # h.Value().(Hash[string, int])
          # h.Value().(map[string]int)
          # ---
          in SyntaxTree::CallNode[
            receiver: receiver,
            operator: SyntaxTree::Period[value: "."],
            message: :call,
            arguments: SyntaxTree::ArgParen[ arguments: SyntaxTree::Args[ parts: [ type ] ] ]
          ]
            SyntaxTree::Go::TypeAssertExpr.new(x: Statements(receiver), type: Statements(type))

          # article.new(Title: "Learning Go")
          # article{Title: "Learning Go"}
          # ---
          in SyntaxTree::CallNode[
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Ident[value: "new"]
          ]
            Statements(node)

          in SyntaxTree::CallNode[
            receiver: receiver,
            operator: SyntaxTree::Period[value: "."],
            message: { value: message },
            arguments: SyntaxTree::ArgParen[arguments: arguments]
          ]
            args, ellipsis = Arguments(arguments&.parts)

            SyntaxTree::Go::CallExpr.new(
              fun: SyntaxTree::Go::SelectorExpr.new(
                x: Statements(receiver),
                sel: Ident(message)
              ),
              args: args,
              ellipsis: ellipsis
            )

          in SyntaxTree::CallNode[
            receiver: nil,
            operator: nil,
            message: (SyntaxTree::Ident | SyntaxTree::Const) => message_node,
            arguments: SyntaxTree::ArgParen[arguments: arguments]
          ]
            args, ellipsis = Arguments(arguments&.parts)

            SyntaxTree::Go::CallExpr.new(
              fun: Ident(message_node.value),
              args: args,
              ellipsis: ellipsis
            )

          in SyntaxTree::CallNode[
            receiver: receiver,
            operator: SyntaxTree::Period[value: "."],
            message: { value: message },
            arguments: nil
          ]
            case receiver
            # @priv.PublicKey
            # &priv.PublicKey
            # ---
            in SyntaxTree::VarRef[value: SyntaxTree::IVar[value: name]]
              SyntaxTree::Go::UnaryExpr.new(
                op: :&,
                x: SyntaxTree::Go::SelectorExpr.new(
                  x:   Ident(name.delete_prefix("@")),
                  sel: Ident(message)
                )
              )

            # @@ast.Ident
            # *ast.Ident
            # ---
            in SyntaxTree::VarRef[value: SyntaxTree::CVar[value: name]]
              SyntaxTree::Go::StarExpr.new(
                x: SyntaxTree::Go::SelectorExpr.new(
                  x:   Ident(name.delete_prefix("@@")),
                  sel: Ident(message)
                )
              )

            else
              SyntaxTree::Go::SelectorExpr.new(x: LeftHand(receiver), sel: Ident(message))
            end

          else
            nil
          end
        end

      end

      module StatementNodes
        def Package(name:, declarations:)
          SyntaxTree::Go::File.new(
            name: SyntaxTree::Go::Ident.new(name: name.to_s),
            decls: declarations
          )
        end

        def LeftHand(node)
          case node
          in SyntaxTree::CallNode
            Call(node)

          in SyntaxTree::ARefField[ collection: collection, index: SyntaxTree::Args[ parts: [ index ] ] ]
            SyntaxTree::Go::IndexExpr.new(x: Statements(collection), index: Statements(index))

          in SyntaxTree::MLHS[parts: parts]
            parts.map { |part| LeftHand(part) }

          in SyntaxTree::MRHS[parts: parts]
            parts.map { |part| LeftHand(part) }

          in SyntaxTree::Int[value: text]
            IntLiteral(text)

          in SyntaxTree::FloatLiteral[value: text]
            FloatLiteral(text)

          in SyntaxTree::Binary[left: left, operator: operator, right: right] => binary
            Binary(Statements(left), operator, Statements(right), location: binary.location)



          in SyntaxTree::VarField[value: value]
            LeftHand(value)

          in SyntaxTree::VCall[value: value]
            LeftHand(value)

          in SyntaxTree::Field[parent: parent, operator: SyntaxTree::Period[value: "."], name: { value: name }]
            SyntaxTree::Go::SelectorExpr.new(x: LeftHand(parent), sel: Ident(name))

          in SyntaxTree::StringLiteral[parts: [SyntaxTree::TStringContent[value: text]], quote: quote]
            quote == "'" ? CharLiteral(text) : StringLiteral(text)

          in SyntaxTree::StringLiteral[parts: []]
            StringLiteral("")

          in SyntaxTree::XStringLiteral[parts: [SyntaxTree::TStringContent[value: text]]]
            RawStringLiteral(text)

          else
            Variable(node)
          end
        end

        def RightHand(node) = Statements(node)

        # city = "Wellington"
        # city := "Wellington"
        # ---
        # x, y = 10, 20.5
        # x, y = 10, 20.5
        # ---
        def Assignment(ctx, target, value)
          lhs = Array(LeftHand(target))
          names = lhs.grep(SyntaxTree::Go::Ident).map(&:name) - ["_"]

          SyntaxTree::Go::AssignStmt.new(
            lhs:     lhs,
            tok_pos: nil,
            tok:     ctx.declare(names).any? ? ":=" : "=",
            rhs:     Array(RightHand(value))
          )
        end

        # var :name, string, "Nathan"
        # var name string = "Nathan"
        # ---
        # const :greeting, "hi"
        # const greeting = "hi"
        # ---
        def Declaration(tok, variable, type, value)
          declare([variable])

          SyntaxTree::Go::GenDecl.new(
            tok: tok,
            specs: [
              SyntaxTree::Go::ValueSpec.new(
                names:  [Ident(variable)],
                type:   type && Statements(type),
                values: value ? [Statements(value)] : []
              )
            ]
          )
        end

        # runtime: runRuntime
        # "runtime": runRuntime
        # ---
        def Entry(type, entry)
          case [type, entry]
          in [SyntaxTree::Go::MapType, SyntaxTree::Go::KeyValueExpr[key: SyntaxTree::Go::Ident[name: name], value: value]]
            SyntaxTree::Go::KeyValueExpr.new(key: StringLiteral(name), value: value)

          else
            entry
          end
        end

        def Command(name, args)
          case [name, args]
          in ["require", [SyntaxTree::StringLiteral[parts: [SyntaxTree::TStringContent[value: path]]]]]
            ImportSpec(path)

          # require "encoding/json/v2", json
          # json "encoding/json/v2"
          # ---
          in ["require", [SyntaxTree::StringLiteral[parts: [SyntaxTree::TStringContent[value: path]]], name]]
            ImportSpec(path, name: Statements(name))

          # defer h.Delete()
          # defer h.Delete()
          # ---
          in ["defer", [call]]
            SyntaxTree::Go::DeferStmt.new(call: Statements(call))

          # var demos = Hash[string, Proc].new(...)
          # var demos = map[string]func(){...}
          # ---
          in ["var" | "const" => tok, [SyntaxTree::Assign[target: target, value: value]]]
            declare(Array(LeftHand(target)).grep(SyntaxTree::Go::Ident).map(&:name))

            SyntaxTree::Go::GenDecl.new(
              tok: tok.to_sym,
              specs: [ SyntaxTree::Go::ValueSpec.new( names: [LeftHand(target)], values: [RightHand(value)] ) ]
            )

          # var mixed Array[byte, 16]
          # var mixed [16]byte
          # ---
          in ["var", [SyntaxTree::Command[
            message: SyntaxTree::Ident[value: variable],
            arguments: SyntaxTree::Args[ parts: [ type ] ]
          ]]]
            Declaration(:var, variable, type, nil)

          # var :a, int
          # var a int
          # ---
          in ["var", [SyntaxTree::SymbolLiteral[value: { value: variable }], type]]
            Declaration(:var, variable, type, nil)

          # var :name, string, "Nathan"
          # var name string = "Nathan"
          # ---
          in ["var", [SyntaxTree::SymbolLiteral[value: { value: variable }], type, value]]
            Declaration(:var, variable, type, value)

          # const :greeting, string, "hi"
          # const greeting string = "hi"
          # ---
          in ["const", [SyntaxTree::SymbolLiteral[value: { value: variable }], type, value]]
            Declaration(:const, variable, type, value)

          # const :greeting, "hi"
          # const greeting = "hi"
          # ---
          in ["const", [SyntaxTree::SymbolLiteral[value: { value: variable }], value]]
            Declaration(:const, variable, nil, value)

          else
            nil
          end
        end

        def Statements(node)
          case node
          in SyntaxTree::Assign[
            target: SyntaxTree::VarField[value: SyntaxTree::Ident[value: "err"]],
            value: SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: "getSomeValue"],
              arguments: SyntaxTree::ArgParen[arguments: nil]
            ]
          ]
            nil


          # Hash[string, bool]
          # map[string]bool
          # ---
          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[value: SyntaxTree::Const[value: "Hash"]],
            index: SyntaxTree::Args[ parts: [ key, value ] ]
          ]
            SyntaxTree::Go::MapType.new(
              key:   Statements(key),
              value: Statements(value)
            )

          # Chan[int]
          # chan int
          # ---
          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Chan" ] ],
            index: SyntaxTree::Args[ parts: [ type ] ]
          ]
            SyntaxTree::Go::ChanType.new(dir: 3, value: Statements(type))

          # Array[string]
          # []string
          # ---
          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Array" ] ],
            index: SyntaxTree::Args[ parts: [ type ] ]
          ]
            SyntaxTree::Go::ArrayType.new( len: nil, elt: Statements(type) )

          # Array[string, 5]
          # [5]string
          # ---
          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Array" ] ],
            index: SyntaxTree::Args[ parts: [ type, size ] ]
          ]
            SyntaxTree::Go::ArrayType.new( len: Statements(size), elt: Statements(type) )

          # Proc[ksuid.KSUID]
          # func(ksuid.KSUID)
          # ---
          in SyntaxTree::ARef[
            collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Proc" ] ],
            index: SyntaxTree::Args[ parts: parts ]
          ]
            return_parts =
              case parts.last
              in SyntaxTree::ArrayLiteral[contents: SyntaxTree::Args[parts: rets]]
                rets
              else
                nil
              end
            param_parts = return_parts ? parts[0...-1] : parts
            SyntaxTree::Go::FuncType.new(
              params: SyntaxTree::Go::FieldList.new(
                list: param_parts.map { |part| SyntaxTree::Go::Field.new(type: Statements(part)) }
              ),
              results: return_parts ? SyntaxTree::Go::FieldList.new(list: return_parts.map { |r| SyntaxTree::Go::Field.new(type: Statements(r)) }) : nil
            )

          # Proc
          # func()
          # ---
          in SyntaxTree::VarRef[ value: SyntaxTree::Const[ value: "Proc" ] ]
            SyntaxTree::Go::FuncType.new(
              params:  SyntaxTree::Go::FieldList.new(list: []),
              results: nil
            )

          # Array[byte].new("hello")
          # []byte("hello")
          # ---
          # Array[byte].new(text)
          # []byte(text)
          # ---
          in SyntaxTree::CallNode[
            receiver: SyntaxTree::ARef[
              collection: SyntaxTree::VarRef[ value: SyntaxTree::Const[value: "Array"] ],
              index: SyntaxTree::Args[
                parts: [ SyntaxTree::VCall[value: SyntaxTree::Ident[value: "byte" | "rune"]] ]
              ]
            ] => receiver,
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Ident[value: "new"],
            arguments: SyntaxTree::ArgParen[
              arguments: SyntaxTree::Args[ parts: [ value ] ]
            ]
          ]
            SyntaxTree::Go::CallExpr.new(
              fun:  Statements(receiver),
              args: [ Statements(value) ]
            )

          # @url.URL.new(Scheme: "https")
          # &url.URL{Scheme: "https"}
          # ---
          in SyntaxTree::CallNode[
            receiver: SyntaxTree::CallNode[
              receiver: SyntaxTree::VarRef[ value: SyntaxTree::IVar[value: name] ],
              operator: SyntaxTree::Period[value: "."],
              message: { value: selector }
            ],
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Ident[value: "new"],
            arguments: arguments
          ]
            SyntaxTree::Go::UnaryExpr.new(
              op: :&,
              x: SyntaxTree::Go::CompositeLit.new(
                type: SyntaxTree::Go::SelectorExpr.new(
                  x:   Ident(name.delete_prefix("@")),
                  sel: Ident(selector)
                ),
                elts: Array(arguments&.arguments&.parts).flat_map { |item| Statements(item) },
                location: arguments&.location || SyntaxTree::Location.default
              )
            )

          # Array[string].new("go", "stdlib")
          # Hash[string, int].new("answer" => 42)
          # article.new(Title: "Learning Go")
          # []string{"go", "stdlib"}
          # map[string]int{"answer": 42}
          # article{Title: "Learning Go"}
          # ---
          in SyntaxTree::CallNode[
            receiver: receiver,
            operator: SyntaxTree::Period[value: "."],
            message: SyntaxTree::Ident[value: "new"],
            arguments: arguments
          ]
            Statements(receiver).then do |type|
              SyntaxTree::Go::CompositeLit.new(
                type: type,
                elts: Array(arguments&.arguments&.parts).flat_map { |item|
                  Array(Statements(item)).map { |entry| Entry(type, entry) }
                },
                location: arguments&.location || SyntaxTree::Location.default
              )
            end

          # Title: "Learning Go"
          # Title: "Learning Go"
          # ---
          in SyntaxTree::BareAssocHash[ assocs: assocs ]
            assocs.map { |assoc| Statements(assoc) }

          in SyntaxTree::Assoc[
            key: SyntaxTree::Label[value: label],
            value: value
          ]
            SyntaxTree::Go::KeyValueExpr.new(
              key:   Ident(label.delete_suffix(":")),
              value: Statements(value)
            )

          # "q": ["go & rust"]
          # "q": {"go & rust"}
          # ---
          in SyntaxTree::Assoc[
            key: SyntaxTree::DynaSymbol[parts: [SyntaxTree::TStringContent[value: text]]],
            value: value
          ]
            SyntaxTree::Go::KeyValueExpr.new(
              key:   StringLiteral(text),
              value: Statements(value)
            )

          in SyntaxTree::Assoc[ key: key, value: value ]
            SyntaxTree::Go::KeyValueExpr.new(
              key:   Statements(key),
              value: Statements(value)
            )

          # { Name: "session", Value: "abc123" }
          # {Name: "session", Value: "abc123"}
          # ---
          in SyntaxTree::HashLiteral[ assocs: assocs ] => hash
            SyntaxTree::Go::CompositeLit.new(
              type: nil,
              elts: assocs.map { |assoc| Statements(assoc) },
              location: hash.location
            )

          # ["go & rust"]
          # {"go & rust"}
          # ---
          in SyntaxTree::ArrayLiteral[ contents: SyntaxTree::Args[ parts: parts ] ] => array
            SyntaxTree::Go::CompositeLit.new(
              type: nil,
              elts: parts.map { |part| Statements(part) },
              location: array.location
            )

          # digest[]
          # digest[:]
          # ---
          in SyntaxTree::ARef[ collection: collection, index: nil ]
            SyntaxTree::Go::SliceExpr.new(x: Statements(collection), low: nil, high: nil)

          # snippet[...400]
          # snippet[:400]
          # ---
          in SyntaxTree::ARef[
            collection: collection,
            index: SyntaxTree::Args[ parts: [ SyntaxTree::RangeNode[ left: low, right: high ] ] ]
          ]
            SyntaxTree::Go::SliceExpr.new(
              x:    Statements(collection),
              low:  low && Statements(low),
              high: high && Statements(high)
            )

          # demos[os.Args[1]]
          # demos[os.Args[1]]
          # ---
          in SyntaxTree::ARef[ collection: collection, index: SyntaxTree::Args[ parts: [ index ] ] ]
            SyntaxTree::Go::IndexExpr.new(
              x:     Statements(collection),
              index: Statements(index)
            )

          #in SyntaxTree::ARef[collection: collection, index: SyntaxTree::Args[parts: [index]]]
          #  SyntaxTree::Go::IndexExpr.new(
          #    x: LeftHand(collection),
          #    index: LeftHand(index)
          #  )

          #in SyntaxTree::ARefField[collection: collection, index: SyntaxTree::Args[parts: [index]]]
          #  SyntaxTree::Go::IndexExpr.new(
          #    x: LeftHand(collection),
          #    index: LeftHand(index)
          #  )

          #in SyntaxTree::Go::ReturnStmt
          #  SyntaxTree::Go::ReturnStmt.new(return_: nil, results: nil)

          #in SyntaxTree::Go::IncDecStmt
          #  SyntaxTree::Go::IncDecStmt.new(x: nil, tok_pos: nil, tok: nil)

          #in SyntaxTree::Go::ExprStmt
          #  SyntaxTree::Go::ExprStmt.new(x: nil)

          #in SyntaxTree::Go::IndexExpr
          #  SyntaxTree::Go::IndexStmt.new(x: nil)

          #in SyntaxTree::Go::SliceExpr
          #  SyntaxTree::Go::SliceStmt.new(x: nil)

          #in SyntaxTree::Go::SelectorExpr
          #  SyntaxTree::Go::SelectorExpr.new(x: nil)

          #in SyntaxTree::Go::ArrayType
          #  SyntaxTree::Go::ArrayType.new(x: nil)

          #in SyntaxTree::Go::MapType
          #  SyntaxTree::Go::MapType.new(x: nil)

          #in SyntaxTree::Go::StarExpr
          #  SyntaxTree::Go::StarExpr.new(x: nil)

          #in SyntaxTree::Go::UnaryExpr
          #  SyntaxTree::Go::UnaryExpr.new(x: nil)
 
          #in SyntaxTree::Go::KeyValueExpr
          #  SyntaxTree::Go::KeyValueExpr.new(x: nil)
 
          #in SyntaxTree::Go::CompositeLit
          #  SyntaxTree::Go::CompositeLit.new(x: nil)

          # (digit - 'A')
          # (digit - 'A')
          # ---
          in SyntaxTree::Paren[contents: SyntaxTree::Statements[body: [statement]]]
            SyntaxTree::Go::ParenExpr.new(x: Statements(statement))

          in SyntaxTree::Command[
            message: SyntaxTree::Ident[value: name],
            arguments: SyntaxTree::Args[parts: args]
          ]
            Command(name, args)

          in SyntaxTree::MRHS[parts: parts]
            parts.map { |part| Statements(part) }

          in SyntaxTree::CallNode
            Call(node)

          in SyntaxTree::Assign[target: target, value: value]
            Assignment(self, target, value)

          in SyntaxTree::MAssign[
            target: SyntaxTree::MLHS[
              parts: [
                SyntaxTree::VarField[value: SyntaxTree::Ident[value: "_"]],
                SyntaxTree::VarField[value: SyntaxTree::Ident[value: "err"]]
              ]
            ],
            value: SyntaxTree::CallNode[
              receiver: nil,
              operator: nil,
              message: SyntaxTree::Ident[value: "getSomeValue"],
              arguments: SyntaxTree::ArgParen[arguments: nil]
            ]
          ]
            nil

          in SyntaxTree::MAssign[target: target, value: value]
            Assignment(self, target, value)

          in SyntaxTree::MethodAddBlock[
            call: SyntaxTree::CallNode[
              receiver: SyntaxTree::Paren[
                contents: SyntaxTree::Statements[
                  body: [
                    SyntaxTree::RangeNode[
                      left: SyntaxTree::Int[value: "1"],
                      operator: SyntaxTree::Op[value: ".."],
                      right: SyntaxTree::Int[value: "5"]
                    ]
                  ]
                ]
              ],
              operator: SyntaxTree::Period[value: "."],
              message: SyntaxTree::Ident[value: "each"]
            ],
            block: SyntaxTree::BlockNode[
              block_var: SyntaxTree::BlockVar[
                params: SyntaxTree::Params[
                  requireds: [SyntaxTree::Ident[value: "i"]]
                ]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[
                  body: [SyntaxTree::VarRef[value: SyntaxTree::Ident[value: "i"]]]
                ]
              ]
            ]
          ]
            nil

          # lambda { |w, r| ... }
          # func(w http.ResponseWriter, r *http.Request) { ... }
          # ---
          in SyntaxTree::MethodAddBlock[
            call: SyntaxTree::CallNode[ message: SyntaxTree::Ident[value: "lambda"] ],
            block: block
          ]
            Lambda(block)

          # 1 << 6
          # 1 << 6
          # ---
          in SyntaxTree::Binary[ left: left, operator: :<<, right: right ] => binary
            Binary(Statements(left), :<<, Statements(right), location: binary.location)

          # break
          # break
          # ---
          in SyntaxTree::Break
            SyntaxTree::Go::BranchStmt.new(tok: :break)

          # next
          # continue
          # ---
          in SyntaxTree::Next
            SyntaxTree::Go::BranchStmt.new(tok: :continue)

          # return "discarded", "kept"
          # return "discarded", "kept"
          # ---
          in SyntaxTree::ReturnNode[arguments: SyntaxTree::Args[ parts: parts ]]
            SyntaxTree::Go::ReturnStmt.new(results: parts.map { |part| Statements(part) })

          # return
          # return
          # ---
          in SyntaxTree::ReturnNode
            SyntaxTree::Go::ReturnStmt.new(results: [])

          # ~time.After(50 * time.Millisecond)
          # <-time.After(50 * time.Millisecond)
          # ---
          in SyntaxTree::Unary[ operator: "~", statement: statement ]
            Receive(Statements(statement))

          # -12345
          # -12345
          # ---
          in SyntaxTree::Unary[ operator: operator, statement: statement ]
            SyntaxTree::Go::UnaryExpr.new(op: operator.to_sym, x: Statements(statement))

          # :int32
          # int32
          # ---
          in SyntaxTree::SymbolLiteral[value: SyntaxTree::Ident[value: name]]
            Ident(name)

          in SyntaxTree::VoidStmt
            nil
          else
            LeftHand(node)
          end
        end

        def ImportSpec(path, name: nil)
          SyntaxTree::Go::ImportSpec.new(
            doc: nil,
            name: name,
            path: StringLiteral(path),
            comment: nil,
            end_pos: nil
          )
        end

      end

      def call(node)
        root_context = Context.new(node.statements.body)

        root_context.match do
          before do |ctx|
          end

          iterate do |ctx, node|
            case node
            in SyntaxTree::ModuleDeclaration[
              constant: SyntaxTree::ConstRef[
                constant: SyntaxTree::Const[value: name]
              ],
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.state[:package] = name == "Main" ? "main" : name.downcase
              Hoist.new(body)

            # type :uint128, Array[uint64, 2] do def M ... end end
            # type uint128 [2]uint64
            # func (self *uint128) M() { ... }
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "type"],
              arguments: SyntaxTree::Args[ parts: [
                SyntaxTree::SymbolLiteral[value: { value: name }], type
              ] ],
              block: SyntaxTree::BlockNode[
                bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[ body: methods ] ]
              ]
            ]
              [ Alias(name, type), *Methods(name, methods) ]

            # type :CompressedSet, Array[byte]
            # type CompressedSet []byte
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "type"],
              arguments: SyntaxTree::Args[ parts: [
                SyntaxTree::SymbolLiteral[value: { value: name }], type
              ] ]
            ]
              Alias(name, type)

            # var colour = Struct.new(R: byte) do def M ... end end
            # type colour struct { R byte }
            # func (self colour) M() { ... }
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var"],
              arguments: SyntaxTree::Args[ parts: [ SyntaxTree::Assign[
                target: SyntaxTree::VarField[ value: { value: name } ],
                value: SyntaxTree::CallNode[
                  receiver: SyntaxTree::VarRef[ value: SyntaxTree::Const[value: "Struct"] ],
                  message: SyntaxTree::Ident[value: "new"],
                  arguments: SyntaxTree::ArgParen[ arguments: SyntaxTree::Args[
                    parts: [ SyntaxTree::BareAssocHash[ assocs: assocs ] ]
                  ] ]
                ]
              ] ] ],
              block: SyntaxTree::BlockNode[
                bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[ body: methods ] ]
              ]
            ]
              [ TypeDecl(name, Fields(assocs)), *Methods(name, methods) ]

            # var todosResource = Struct.new() do ... end
            # type todosResource struct {}
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var"],
              arguments: SyntaxTree::Args[ parts: [ SyntaxTree::Assign[
                target: SyntaxTree::VarField[ value: { value: name } ],
                value: SyntaxTree::CallNode[
                  receiver: SyntaxTree::VarRef[ value: SyntaxTree::Const[value: "Struct"] ],
                  message: SyntaxTree::Ident[value: "new"],
                  arguments: SyntaxTree::ArgParen[ arguments: nil ]
                ]
              ] ] ],
              block: SyntaxTree::BlockNode[
                bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[ body: methods ] ]
              ]
            ]
              [ TypeDecl(name, []), *Methods(name, methods) ]

            # var person = Struct.new(Name: string, Age: int)
            # type person struct { Name string; Age int }
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var"],
              arguments: SyntaxTree::Args[ parts: [ SyntaxTree::Assign[
                target: SyntaxTree::VarField[ value: { value: name } ],
                value: SyntaxTree::CallNode[
                  receiver: SyntaxTree::VarRef[ value: SyntaxTree::Const[value: "Struct"] ],
                  message: SyntaxTree::Ident[value: "new"],
                  arguments: SyntaxTree::ArgParen[ arguments: SyntaxTree::Args[
                    parts: [ SyntaxTree::BareAssocHash[ assocs: assocs ] ]
                  ] ]
                ]
              ] ] ]
            ]
              TypeDecl(name, Fields(assocs))

            # var todosResource = Struct.new()
            # type todosResource struct {}
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var"],
              arguments: SyntaxTree::Args[ parts: [ SyntaxTree::Assign[
                target: SyntaxTree::VarField[ value: { value: name } ],
                value: SyntaxTree::CallNode[
                  receiver: SyntaxTree::VarRef[ value: SyntaxTree::Const[value: "Struct"] ],
                  message: SyntaxTree::Ident[value: "new"],
                  arguments: SyntaxTree::ArgParen[ arguments: nil ]
                ]
              ] ] ]
            ]
              TypeDecl(name, [])

            # var KSUID = Class.new(Array[byte, BYTE_LENGTH]) do ... end
            # type KSUID [byteLength]byte
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var"],
              arguments: SyntaxTree::Args[ parts: [ SyntaxTree::Assign[
                target: SyntaxTree::VarField[ value: { value: name } ],
                value: SyntaxTree::CallNode[
                  receiver: SyntaxTree::VarRef[ value: SyntaxTree::Const[value: "Class"] ],
                  message: SyntaxTree::Ident[value: "new"],
                  arguments: SyntaxTree::ArgParen[ arguments: SyntaxTree::Args[
                    parts: [ type ]
                  ] ]
                ]
              ] ] ],
              block: SyntaxTree::BlockNode[
                bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[ body: methods ] ]
              ]
            ]
              already_defined = ctx.tree.flatten.any? do |n|
                n.is_a?(SyntaxTree::Go::GenDecl) && n.tok == :type && n.specs.any? { |s| s.respond_to?(:name) && s.name.respond_to?(:name) && s.name.name == name }
              end

              if already_defined
                Methods(name, methods)
              else
                [ TypeDefinition(name, type), *Methods(name, methods) ]
              end

            # var CompressedSet = Class.new(Array[byte])
            # type CompressedSet []byte
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "var"],
              arguments: SyntaxTree::Args[ parts: [ SyntaxTree::Assign[
                target: SyntaxTree::VarField[ value: { value: name } ],
                value: SyntaxTree::CallNode[
                  receiver: SyntaxTree::VarRef[ value: SyntaxTree::Const[value: "Class"] ],
                  message: SyntaxTree::Ident[value: "new"],
                  arguments: SyntaxTree::ArgParen[ arguments: SyntaxTree::Args[
                    parts: [ type ]
                  ] ]
                ]
              ] ] ]
            ]
              TypeDefinition(name, type)

            # class Args
            # type Args struct { ... }
            # ---
            in SyntaxTree::ClassDeclaration[
              constant: SyntaxTree::ConstRef[ constant: SyntaxTree::Const[value: name] ],
              bodystmt: SyntaxTree::BodyStmt[ statements: SyntaxTree::Statements[ body: body ] ]
            ]
              [ TypeDecl(name, Fields(body)), *Methods(name, body) ]

            in SyntaxTree::DefNode[
              name: { value: name },
              params: { contents: SyntaxTree::Params[requireds: args], comments: [SyntaxTree::Comment[value: types], *] } => params,
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              return_names = parse_signature_comment(types)[:returns].filter_map { |ret| ret[:name] }
              ctx.descend(body, declared: [*args.map(&:value), *return_names]).then do |children|
                Function(name: name, params: params, body: children.tree)
              end

            in SyntaxTree::DefNode[
              name: { value: name },
              params: { contents: SyntaxTree::Params[requireds: args] } => params,
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body, declared: args.map(&:value)).then do |children|
                Function(name: name, params: params, body: children.tree)
              end

            in SyntaxTree::DefNode[
              name: { value: name },
              params: { comments: [SyntaxTree::Comment[value: types], *] } => params,
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              return_names = parse_signature_comment(types)[:returns].filter_map { |ret| ret[:name] }
              ctx.descend(body, declared: return_names).then do |children|
                Function(name: name, params: params, body: children.tree)
              end

            in SyntaxTree::DefNode[
              name: { value: name },
              params: params,
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body).then do |children|
                Function(name: name, params: params, body: children.tree)
              end

            in SyntaxTree::Begin[
              bodystmt: SyntaxTree::BodyStmt[
                statements: SyntaxTree::Statements[body: body]
              ]
            ]
              ctx.descend(body, inherit: false).then do |children|
                Block(body: children.tree)
              end

            in SyntaxTree::IfNode | SyntaxTree::UnlessNode | SyntaxTree::WhileNode | SyntaxTree::UntilNode |
              SyntaxTree::Case |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[ message: SyntaxTree::Ident[value: "times"] ]] |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[ message: SyntaxTree::Ident[value: "loop"] ]] |
              SyntaxTree::MethodAddBlock[call: SyntaxTree::CallNode[ message: SyntaxTree::Ident[value: "each"] ]] => logic_node
              Logic(ctx, logic_node)

            # go lambda { ... }.()
            # go func() { ... }()
            # ---
            in SyntaxTree::Command[
              message: SyntaxTree::Ident[value: "go"],
              arguments: SyntaxTree::Args[ parts: [
                SyntaxTree::CallNode[
                  receiver: SyntaxTree::MethodAddBlock[
                    call: SyntaxTree::CallNode[ message: SyntaxTree::Ident[value: "lambda"] ],
                    block: block
                  ],
                  operator: SyntaxTree::Period[value: "."],
                  message: :call,
                  arguments: SyntaxTree::ArgParen[ arguments: arguments ]
                ]
              ] ]
            ]
              SyntaxTree::Go::GoStmt.new(
                call: SyntaxTree::Go::CallExpr.new(
                  fun:  Lambda(block),
                  args: Array(arguments&.parts).map { |argument| Statements(argument) }
                )
              )

            # ch << "ping"
            # ch <- "ping"
            # ---
            in SyntaxTree::Binary[ left: left, operator: :<<, right: right ]
              SyntaxTree::Go::SendStmt.new(chan: Statements(left), value: Statements(right))

            in SyntaxTree::CallNode
              SyntaxTree::Go::ExprStmt.new(x: Statements(node))

            in SyntaxTree::Comment[value: value]
              SyntaxTree::Go::Comment.new(text: value.sub(/\A#/, "//"))

            # PI = 3.14159
            # const pi = 3.14159
            # ---
            in SyntaxTree::Assign[
              target: SyntaxTree::VarField[value: SyntaxTree::Const[value: name]],
              value: value
            ] if ctx.equal?(root_context)
              ctx.state[:uppercase_constants] = (ctx.state[:uppercase_constants] || []) | [name]
              SyntaxTree::Go::GenDecl.new(
                tok: :const,
                specs: [ SyntaxTree::Go::ValueSpec.new( names: [Constant(name)], values: [RightHand(value)] ) ]
              )

            # packageLevel = "I live at package scope"
            # var packageLevel = "I live at package scope"
            # ---
            in SyntaxTree::Assign[target: target, value: value] if ctx.equal?(root_context)
              SyntaxTree::Go::GenDecl.new(
                tok: :var,
                specs: [ SyntaxTree::Go::ValueSpec.new( names: [LeftHand(target)], values: [RightHand(value)] ) ]
              )

            in SyntaxTree::Assign[target: target, value: value]
              Assignment(ctx, target, value)

            in SyntaxTree::MAssign[target: target, value: value]
              Assignment(ctx, target, value)

            in SyntaxTree::OpAssign[target: target, operator: SyntaxTree::Op[value: op], value: value]
              lhs = LeftHand(target)
              rhs = RightHand(value)
              if ["+=", "-="].include?(op) && rhs.is_a?(SyntaxTree::Go::BasicLit) && rhs.kind == :INT && rhs.value == "1"
                SyntaxTree::Go::IncDecStmt.new(x: lhs, tok: op == "+=" ? :"++" : :"--", tok_pos: nil)
              else
                SyntaxTree::Go::AssignStmt.new(
                  lhs:     Array(lhs),
                  tok_pos: nil,
                  tok:     op.to_sym,
                  rhs:     Array(rhs)
                )
              end

            else
              Statements(node)
            end
          end

          after do |ctx|
            if ctx.equal?(root_context)
              # a declaration may arrive with its methods alongside it
              ctx.tree.replace(ctx.tree.flatten)


              ctx.tree.unshift(SyntaxTree::Go::GenDecl.new(
                tok: :import,
                specs: ctx.tree.select { |node| node.is_a?(SyntaxTree::Go::ImportSpec) }
              ))
              ctx.tree.reject! { |node| node.is_a?(SyntaxTree::Go::ImportSpec) }

              [:const, :var].each do |tok|
                decls = ctx.tree.select { |node| node.is_a?(SyntaxTree::Go::GenDecl) && node.tok == tok }
                next if decls.length < 2

                first_index = ctx.tree.index { |node| node.equal?(decls.first) }
                last_index  = ctx.tree.rindex { |node| node.equal?(decls.last) }
                range = ctx.tree[first_index..last_index]

                grouped = SyntaxTree::Go::GenDecl.new(tok: tok, specs: range.flat_map { |node|
                  case node
                  # consecutive `#` lines are one block comment, so they wait in
                  # state until the spec they were written against arrives
                  in SyntaxTree::Go::Comment
                    ctx.state.fetch(:comments) << node
                    []

                  in SyntaxTree::Go::GenDecl[tok: ^tok, specs: specs]
                    [*ctx.state.fetch(:comments).slice!(0..), *specs]

                  else
                    []
                  end
                })

                replaced = ctx.tree[0...first_index] + [grouped] + ctx.tree[(last_index + 1)..]
                ctx.tree.replace(replaced)
              end

              file = Package(name: ctx.state[:package] || "main", declarations: ctx.tree.dup)
              ctx.tree.replace([file])
            end
          end
        end

        root_context.tree.first
      end
    end

    class Context
      include Runner::DefinitionNodes
      include Runner::StatementNodes

      include Runner::LogicNodes
      include Runner::LambdaNodes
      include Runner::BlockNodes
      include Runner::VariableNodes
    end
  end
end
