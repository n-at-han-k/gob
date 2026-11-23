module SyntaxTree::Go
  class Comment < Node
    attr_reader(:slash, :text, :location, :comments)
    def initialize(
      slash: nil,
      text: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @slash = slash
      @text = text
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_comment(self)
    end
    def child_nodes
      []
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { slash: @slash, text: @text, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(Comment) && @slash === other.slash && @text === other.text
    end
  end
  class CommentGroup < Node
    attr_reader(:list, :location, :comments)
    def initialize(
      list: [],
      location: SyntaxTree::Location.default,
      comments: []
    )
      @list = list
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_comment_group(self)
    end
    def child_nodes
      [@list].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { list: @list, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(CommentGroup) && @list === other.list
    end
  end
  class Field < Node
    attr_reader(:doc, :names, :type, :tag, :comment, :location, :comments)
    def initialize(
      doc: nil,
      names: [],
      type: nil,
      tag: nil,
      comment: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @doc = doc
      @names = names
      @type = type
      @tag = tag
      @comment = comment
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_field(self)
    end
    def child_nodes
      [@doc, @names, @type, @tag, @comment].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        doc: @doc,
        names: @names,
        type: @type,
        tag: @tag,
        comment: @comment,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(Field) && @doc === other.doc && @names === other.names &&
        @type === other.type && @tag === other.tag && @comment === other.comment
    end
  end
  class FieldList < Node
    attr_reader(:opening, :list, :closing, :location, :comments)
    def initialize(
      opening: nil,
      list: [],
      closing: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @opening = opening
      @list = list
      @closing = closing
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_field_list(self)
    end
    def child_nodes
      [@list].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        opening: @opening,
        list: @list,
        closing: @closing,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(FieldList) && @opening === other.opening &&
        @list === other.list && @closing === other.closing
    end
  end
  class BadExpr < Node
    attr_reader(:from, :to, :location, :comments)
    def initialize(
      from: nil,
      to: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @from = from
      @to = to
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_bad_expr(self)
    end
    def child_nodes
      []
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { from: @from, to: @to, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(BadExpr) && @from === other.from && @to === other.to
    end
  end
  class Ident < Node
    attr_reader(:name_pos, :name, :obj, :location, :comments)
    def initialize(
      name_pos: nil,
      name: nil,
      obj: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @name_pos = name_pos
      @name = name
      @obj = obj
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_ident(self)
    end
    def child_nodes
      []
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        name_pos: @name_pos,
        name: @name,
        obj: @obj,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(Ident) && @name_pos === other.name_pos &&
        @name === other.name && @obj === other.obj
    end
  end
  class Ellipsis < Node
    attr_reader(:ellipsis, :elt, :location, :comments)
    def initialize(
      ellipsis: nil,
      elt: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @ellipsis = ellipsis
      @elt = elt
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_ellipsis(self)
    end
    def child_nodes
      [@elt].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        ellipsis: @ellipsis,
        elt: @elt,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(Ellipsis) && @ellipsis === other.ellipsis &&
        @elt === other.elt
    end
  end
  class BasicLit < Node
    attr_reader(:value_pos, :value_end, :kind, :value, :location, :comments)
    def initialize(
      value_pos: nil,
      value_end: nil,
      kind: nil,
      value: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @value_pos = value_pos
      @value_end = value_end
      @kind = kind
      @value = value
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_basic_lit(self)
    end
    def child_nodes
      []
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        value_pos: @value_pos,
        value_end: @value_end,
        kind: @kind,
        value: @value,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(BasicLit) && @value_pos === other.value_pos &&
        @value_end === other.value_end && @kind === other.kind &&
        @value === other.value
    end
  end
  class FuncLit < Node
    attr_reader(:type, :body, :location, :comments)
    def initialize(
      type: nil,
      body: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @type = type
      @body = body
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_func_lit(self)
    end
    def child_nodes
      [@type, @body].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { type: @type, body: @body, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(FuncLit) && @type === other.type && @body === other.body
    end
  end
  class CompositeLit < Node
    attr_reader(
      :type,
      :lbrace,
      :elts,
      :rbrace,
      :incomplete,
      :location,
      :comments
    )
    def initialize(
      type: nil,
      lbrace: nil,
      elts: [],
      rbrace: nil,
      incomplete: false,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @type = type
      @lbrace = lbrace
      @elts = elts
      @rbrace = rbrace
      @incomplete = incomplete
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_composite_lit(self)
    end
    def child_nodes
      [@type, @elts].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        type: @type,
        lbrace: @lbrace,
        elts: @elts,
        rbrace: @rbrace,
        incomplete: @incomplete,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(CompositeLit) && @type === other.type &&
        @lbrace === other.lbrace && @elts === other.elts &&
        @rbrace === other.rbrace && @incomplete === other.incomplete
    end
  end
  class ParenExpr < Node
    attr_reader(:lparen, :x, :rparen, :location, :comments)
    def initialize(
      lparen: nil,
      x: nil,
      rparen: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @lparen = lparen
      @x = x
      @rparen = rparen
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_paren_expr(self)
    end
    def child_nodes
      [@x].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        lparen: @lparen,
        x: @x,
        rparen: @rparen,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(ParenExpr) && @lparen === other.lparen && @x === other.x &&
        @rparen === other.rparen
    end
  end
  class SelectorExpr < Node
    attr_reader(:x, :sel, :location, :comments)
    def initialize(
      x: nil,
      sel: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @x = x
      @sel = sel
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_selector_expr(self)
    end
    def child_nodes
      [@x, @sel].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { x: @x, sel: @sel, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(SelectorExpr) && @x === other.x && @sel === other.sel
    end
  end
  class IndexExpr < Node
    attr_reader(:x, :lbrack, :index, :rbrack, :location, :comments)
    def initialize(
      x: nil,
      lbrack: nil,
      index: nil,
      rbrack: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @x = x
      @lbrack = lbrack
      @index = index
      @rbrack = rbrack
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_index_expr(self)
    end
    def child_nodes
      [@x, @index].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        x: @x,
        lbrack: @lbrack,
        index: @index,
        rbrack: @rbrack,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(IndexExpr) && @x === other.x && @lbrack === other.lbrack &&
        @index === other.index && @rbrack === other.rbrack
    end
  end
  class IndexListExpr < Node
    attr_reader(:x, :lbrack, :indices, :rbrack, :location, :comments)
    def initialize(
      x: nil,
      lbrack: nil,
      indices: [],
      rbrack: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @x = x
      @lbrack = lbrack
      @indices = indices
      @rbrack = rbrack
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_index_list_expr(self)
    end
    def child_nodes
      [@x, @indices].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        x: @x,
        lbrack: @lbrack,
        indices: @indices,
        rbrack: @rbrack,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(IndexListExpr) && @x === other.x &&
        @lbrack === other.lbrack && @indices === other.indices &&
        @rbrack === other.rbrack
    end
  end
  class SliceExpr < Node
    attr_reader(
      :x,
      :lbrack,
      :low,
      :high,
      :max,
      :slice3,
      :rbrack,
      :location,
      :comments
    )
    def initialize(
      x: nil,
      lbrack: nil,
      low: nil,
      high: nil,
      max: nil,
      slice3: false,
      rbrack: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @x = x
      @lbrack = lbrack
      @low = low
      @high = high
      @max = max
      @slice3 = slice3
      @rbrack = rbrack
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_slice_expr(self)
    end
    def child_nodes
      [@x, @low, @high, @max].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        x: @x,
        lbrack: @lbrack,
        low: @low,
        high: @high,
        max: @max,
        slice3: @slice3,
        rbrack: @rbrack,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(SliceExpr) && @x === other.x && @lbrack === other.lbrack &&
        @low === other.low && @high === other.high && @max === other.max &&
        @slice3 === other.slice3 && @rbrack === other.rbrack
    end
  end
  class TypeAssertExpr < Node
    attr_reader(:x, :lparen, :type, :rparen, :location, :comments)
    def initialize(
      x: nil,
      lparen: nil,
      type: nil,
      rparen: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @x = x
      @lparen = lparen
      @type = type
      @rparen = rparen
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_type_assert_expr(self)
    end
    def child_nodes
      [@x, @type].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        x: @x,
        lparen: @lparen,
        type: @type,
        rparen: @rparen,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(TypeAssertExpr) && @x === other.x &&
        @lparen === other.lparen && @type === other.type &&
        @rparen === other.rparen
    end
  end
  class CallExpr < Node
    attr_reader(:fun, :lparen, :args, :ellipsis, :rparen, :location, :comments)
    def initialize(
      fun: nil,
      lparen: nil,
      args: [],
      ellipsis: nil,
      rparen: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @fun = fun
      @lparen = lparen
      @args = args
      @ellipsis = ellipsis
      @rparen = rparen
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_call_expr(self)
    end
    def child_nodes
      [@fun, @args].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        fun: @fun,
        lparen: @lparen,
        args: @args,
        ellipsis: @ellipsis,
        rparen: @rparen,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(CallExpr) && @fun === other.fun && @lparen === other.lparen &&
        @args === other.args && @ellipsis === other.ellipsis &&
        @rparen === other.rparen
    end
  end
  class StarExpr < Node
    attr_reader(:star, :x, :location, :comments)
    def initialize(
      star: nil,
      x: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @star = star
      @x = x
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_star_expr(self)
    end
    def child_nodes
      [@x].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { star: @star, x: @x, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(StarExpr) && @star === other.star && @x === other.x
    end
  end
  class UnaryExpr < Node
    attr_reader(:op_pos, :op, :x, :location, :comments)
    def initialize(
      op_pos: nil,
      op: nil,
      x: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @op_pos = op_pos
      @op = op
      @x = x
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_unary_expr(self)
    end
    def child_nodes
      [@x].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        op_pos: @op_pos,
        op: @op,
        x: @x,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(UnaryExpr) && @op_pos === other.op_pos && @op === other.op &&
        @x === other.x
    end
  end
  class BinaryExpr < Node
    attr_reader(:x, :op_pos, :op, :y, :location, :comments)
    def initialize(
      x: nil,
      op_pos: nil,
      op: nil,
      y: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @x = x
      @op_pos = op_pos
      @op = op
      @y = y
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_binary_expr(self)
    end
    def child_nodes
      [@x, @y].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        x: @x,
        op_pos: @op_pos,
        op: @op,
        y: @y,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(BinaryExpr) && @x === other.x && @op_pos === other.op_pos &&
        @op === other.op && @y === other.y
    end
  end
  class KeyValueExpr < Node
    attr_reader(:key, :colon, :value, :location, :comments)
    def initialize(
      key: nil,
      colon: nil,
      value: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @key = key
      @colon = colon
      @value = value
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_key_value_expr(self)
    end
    def child_nodes
      [@key, @value].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        key: @key,
        colon: @colon,
        value: @value,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(KeyValueExpr) && @key === other.key &&
        @colon === other.colon && @value === other.value
    end
  end
  class ArrayType < Node
    attr_reader(:lbrack, :len, :elt, :location, :comments)
    def initialize(
      lbrack: nil,
      len: nil,
      elt: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @lbrack = lbrack
      @len = len
      @elt = elt
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_array_type(self)
    end
    def child_nodes
      [@len, @elt].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        lbrack: @lbrack,
        len: @len,
        elt: @elt,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(ArrayType) && @lbrack === other.lbrack &&
        @len === other.len && @elt === other.elt
    end
  end
  class StructType < Node
    attr_reader(:struct, :fields, :incomplete, :location, :comments)
    def initialize(
      struct: nil,
      fields: nil,
      incomplete: false,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @struct = struct
      @fields = fields
      @incomplete = incomplete
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_struct_type(self)
    end
    def child_nodes
      [@fields].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        struct: @struct,
        fields: @fields,
        incomplete: @incomplete,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(StructType) && @struct === other.struct &&
        @fields === other.fields && @incomplete === other.incomplete
    end
  end
  class FuncType < Node
    attr_reader(:func, :type_params, :params, :results, :location, :comments)
    def initialize(
      func: nil,
      type_params: nil,
      params: nil,
      results: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @func = func
      @type_params = type_params
      @params = params
      @results = results
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_func_type(self)
    end
    def child_nodes
      [@type_params, @params, @results].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        func: @func,
        type_params: @type_params,
        params: @params,
        results: @results,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(FuncType) && @func === other.func &&
        @type_params === other.type_params && @params === other.params &&
        @results === other.results
    end
  end
  class InterfaceType < Node
    attr_reader(:interface, :methods, :incomplete, :location, :comments)
    def initialize(
      interface: nil,
      methods: nil,
      incomplete: false,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @interface = interface
      @methods = methods
      @incomplete = incomplete
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_interface_type(self)
    end
    def child_nodes
      [@methods].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        interface: @interface,
        methods: @methods,
        incomplete: @incomplete,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(InterfaceType) && @interface === other.interface &&
        @methods === other.methods && @incomplete === other.incomplete
    end
  end
  class MapType < Node
    attr_reader(:map, :key, :value, :location, :comments)
    def initialize(
      map: nil,
      key: nil,
      value: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @map = map
      @key = key
      @value = value
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_map_type(self)
    end
    def child_nodes
      [@key, @value].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        map: @map,
        key: @key,
        value: @value,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(MapType) && @map === other.map && @key === other.key &&
        @value === other.value
    end
  end
  class ChanType < Node
    attr_reader(:begin_, :arrow, :dir, :value, :location, :comments)
    def initialize(
      begin_: nil,
      arrow: nil,
      dir: nil,
      value: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @begin_ = begin_
      @arrow = arrow
      @dir = dir
      @value = value
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_chan_type(self)
    end
    def child_nodes
      [@value].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        begin_: @begin_,
        arrow: @arrow,
        dir: @dir,
        value: @value,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(ChanType) && @begin_ === other.begin_ &&
        @arrow === other.arrow && @dir === other.dir && @value === other.value
    end
  end
  class BadStmt < Node
    attr_reader(:from, :to, :location, :comments)
    def initialize(
      from: nil,
      to: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @from = from
      @to = to
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_bad_stmt(self)
    end
    def child_nodes
      []
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { from: @from, to: @to, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(BadStmt) && @from === other.from && @to === other.to
    end
  end
  class DeclStmt < Node
    attr_reader(:decl, :location, :comments)
    def initialize(
      decl: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @decl = decl
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_decl_stmt(self)
    end
    def child_nodes
      [@decl].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { decl: @decl, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(DeclStmt) && @decl === other.decl
    end
  end
  class EmptyStmt < Node
    attr_reader(:semicolon, :implicit, :location, :comments)
    def initialize(
      semicolon: nil,
      implicit: false,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @semicolon = semicolon
      @implicit = implicit
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_empty_stmt(self)
    end
    def child_nodes
      []
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        semicolon: @semicolon,
        implicit: @implicit,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(EmptyStmt) && @semicolon === other.semicolon &&
        @implicit === other.implicit
    end
  end
  class LabeledStmt < Node
    attr_reader(:label, :colon, :stmt, :location, :comments)
    def initialize(
      label: nil,
      colon: nil,
      stmt: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @label = label
      @colon = colon
      @stmt = stmt
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_labeled_stmt(self)
    end
    def child_nodes
      [@label, @stmt].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        label: @label,
        colon: @colon,
        stmt: @stmt,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(LabeledStmt) && @label === other.label &&
        @colon === other.colon && @stmt === other.stmt
    end
  end
  class ExprStmt < Node
    attr_reader(:x, :location, :comments)
    def initialize(x: nil, location: SyntaxTree::Location.default, comments: [])
      @x = x
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_expr_stmt(self)
    end
    def child_nodes
      [@x].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { x: @x, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(ExprStmt) && @x === other.x
    end
  end
  class SendStmt < Node
    attr_reader(:chan, :arrow, :value, :location, :comments)
    def initialize(
      chan: nil,
      arrow: nil,
      value: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @chan = chan
      @arrow = arrow
      @value = value
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_send_stmt(self)
    end
    def child_nodes
      [@chan, @value].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        chan: @chan,
        arrow: @arrow,
        value: @value,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(SendStmt) && @chan === other.chan && @arrow === other.arrow &&
        @value === other.value
    end
  end
  class IncDecStmt < Node
    attr_reader(:x, :tok_pos, :tok, :location, :comments)
    def initialize(
      x: nil,
      tok_pos: nil,
      tok: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @x = x
      @tok_pos = tok_pos
      @tok = tok
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_inc_dec_stmt(self)
    end
    def child_nodes
      [@x].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        x: @x,
        tok_pos: @tok_pos,
        tok: @tok,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(IncDecStmt) && @x === other.x && @tok_pos === other.tok_pos &&
        @tok === other.tok
    end
  end
  class AssignStmt < Node
    attr_reader(:lhs, :tok_pos, :tok, :rhs, :location, :comments)
    def initialize(
      lhs: [],
      tok_pos: nil,
      tok: nil,
      rhs: [],
      location: SyntaxTree::Location.default,
      comments: []
    )
      @lhs = lhs
      @tok_pos = tok_pos
      @tok = tok
      @rhs = rhs
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_assign_stmt(self)
    end
    def child_nodes
      [@lhs, @rhs].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        lhs: @lhs,
        tok_pos: @tok_pos,
        tok: @tok,
        rhs: @rhs,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(AssignStmt) && @lhs === other.lhs &&
        @tok_pos === other.tok_pos && @tok === other.tok && @rhs === other.rhs
    end
  end
  class GoStmt < Node
    attr_reader(:go, :call, :location, :comments)
    def initialize(
      go: nil,
      call: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @go = go
      @call = call
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_go_stmt(self)
    end
    def child_nodes
      [@call].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { go: @go, call: @call, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(GoStmt) && @go === other.go && @call === other.call
    end
  end
  class DeferStmt < Node
    attr_reader(:defer, :call, :location, :comments)
    def initialize(
      defer: nil,
      call: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @defer = defer
      @call = call
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_defer_stmt(self)
    end
    def child_nodes
      [@call].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { defer: @defer, call: @call, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(DeferStmt) && @defer === other.defer && @call === other.call
    end
  end
  class ReturnStmt < Node
    attr_reader(:return_, :results, :location, :comments)
    def initialize(
      return_: nil,
      results: [],
      location: SyntaxTree::Location.default,
      comments: []
    )
      @return_ = return_
      @results = results
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_return_stmt(self)
    end
    def child_nodes
      [@results].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        return_: @return_,
        results: @results,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(ReturnStmt) && @return_ === other.return_ &&
        @results === other.results
    end
  end
  class BranchStmt < Node
    attr_reader(:tok_pos, :tok, :label, :location, :comments)
    def initialize(
      tok_pos: nil,
      tok: nil,
      label: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @tok_pos = tok_pos
      @tok = tok
      @label = label
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_branch_stmt(self)
    end
    def child_nodes
      [@label].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        tok_pos: @tok_pos,
        tok: @tok,
        label: @label,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(BranchStmt) && @tok_pos === other.tok_pos &&
        @tok === other.tok && @label === other.label
    end
  end
  class BlockStmt < Node
    attr_reader(:lbrace, :list, :rbrace, :location, :comments)
    def initialize(
      lbrace: nil,
      list: [],
      rbrace: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @lbrace = lbrace
      @list = list
      @rbrace = rbrace
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_block_stmt(self)
    end
    def child_nodes
      [@list].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        lbrace: @lbrace,
        list: @list,
        rbrace: @rbrace,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(BlockStmt) && @lbrace === other.lbrace &&
        @list === other.list && @rbrace === other.rbrace
    end
  end
  class IfStmt < Node
    attr_reader(:if_, :init, :cond, :body, :else_, :location, :comments)
    def initialize(
      if_: nil,
      init: nil,
      cond: nil,
      body: nil,
      else_: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @if_ = if_
      @init = init
      @cond = cond
      @body = body
      @else_ = else_
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_if_stmt(self)
    end
    def child_nodes
      [@init, @cond, @body, @else_].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        if_: @if_,
        init: @init,
        cond: @cond,
        body: @body,
        else_: @else_,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(IfStmt) && @if_ === other.if_ && @init === other.init &&
        @cond === other.cond && @body === other.body && @else_ === other.else_
    end
  end
  class CaseClause < Node
    attr_reader(:case_, :list, :colon, :body, :location, :comments)
    def initialize(
      case_: nil,
      list: [],
      colon: nil,
      body: [],
      location: SyntaxTree::Location.default,
      comments: []
    )
      @case_ = case_
      @list = list
      @colon = colon
      @body = body
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_case_clause(self)
    end
    def child_nodes
      [@list, @body].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        case_: @case_,
        list: @list,
        colon: @colon,
        body: @body,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(CaseClause) && @case_ === other.case_ &&
        @list === other.list && @colon === other.colon && @body === other.body
    end
  end
  class SwitchStmt < Node
    attr_reader(:switch, :init, :tag, :body, :location, :comments)
    def initialize(
      switch: nil,
      init: nil,
      tag: nil,
      body: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @switch = switch
      @init = init
      @tag = tag
      @body = body
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_switch_stmt(self)
    end
    def child_nodes
      [@init, @tag, @body].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        switch: @switch,
        init: @init,
        tag: @tag,
        body: @body,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(SwitchStmt) && @switch === other.switch &&
        @init === other.init && @tag === other.tag && @body === other.body
    end
  end
  class TypeSwitchStmt < Node
    attr_reader(:switch, :init, :assign, :body, :location, :comments)
    def initialize(
      switch: nil,
      init: nil,
      assign: nil,
      body: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @switch = switch
      @init = init
      @assign = assign
      @body = body
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_type_switch_stmt(self)
    end
    def child_nodes
      [@init, @assign, @body].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        switch: @switch,
        init: @init,
        assign: @assign,
        body: @body,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(TypeSwitchStmt) && @switch === other.switch &&
        @init === other.init && @assign === other.assign && @body === other.body
    end
  end
  class CommClause < Node
    attr_reader(:case_, :comm, :colon, :body, :location, :comments)
    def initialize(
      case_: nil,
      comm: nil,
      colon: nil,
      body: [],
      location: SyntaxTree::Location.default,
      comments: []
    )
      @case_ = case_
      @comm = comm
      @colon = colon
      @body = body
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_comm_clause(self)
    end
    def child_nodes
      [@comm, @body].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        case_: @case_,
        comm: @comm,
        colon: @colon,
        body: @body,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(CommClause) && @case_ === other.case_ &&
        @comm === other.comm && @colon === other.colon && @body === other.body
    end
  end
  class SelectStmt < Node
    attr_reader(:select, :body, :location, :comments)
    def initialize(
      select: nil,
      body: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @select = select
      @body = body
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_select_stmt(self)
    end
    def child_nodes
      [@body].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { select: @select, body: @body, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(SelectStmt) && @select === other.select &&
        @body === other.body
    end
  end
  class ForStmt < Node
    attr_reader(:for_, :init, :cond, :post, :body, :location, :comments)
    def initialize(
      for_: nil,
      init: nil,
      cond: nil,
      post: nil,
      body: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @for_ = for_
      @init = init
      @cond = cond
      @post = post
      @body = body
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_for_stmt(self)
    end
    def child_nodes
      [@init, @cond, @post, @body].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        for_: @for_,
        init: @init,
        cond: @cond,
        post: @post,
        body: @body,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(ForStmt) && @for_ === other.for_ && @init === other.init &&
        @cond === other.cond && @post === other.post && @body === other.body
    end
  end
  class RangeStmt < Node
    attr_reader(
      :for_,
      :key,
      :value,
      :tok_pos,
      :tok,
      :range,
      :x,
      :body,
      :location,
      :comments
    )
    def initialize(
      for_: nil,
      key: nil,
      value: nil,
      tok_pos: nil,
      tok: nil,
      range: nil,
      x: nil,
      body: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @for_ = for_
      @key = key
      @value = value
      @tok_pos = tok_pos
      @tok = tok
      @range = range
      @x = x
      @body = body
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_range_stmt(self)
    end
    def child_nodes
      [@key, @value, @x, @body].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        for_: @for_,
        key: @key,
        value: @value,
        tok_pos: @tok_pos,
        tok: @tok,
        range: @range,
        x: @x,
        body: @body,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(RangeStmt) && @for_ === other.for_ && @key === other.key &&
        @value === other.value && @tok_pos === other.tok_pos &&
        @tok === other.tok && @range === other.range && @x === other.x &&
        @body === other.body
    end
  end
  class ImportSpec < Node
    attr_reader(:doc, :name, :path, :comment, :end_pos, :location, :comments)
    def initialize(
      doc: nil,
      name: nil,
      path: nil,
      comment: nil,
      end_pos: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @doc = doc
      @name = name
      @path = path
      @comment = comment
      @end_pos = end_pos
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_import_spec(self)
    end
    def child_nodes
      [@doc, @name, @path, @comment].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        doc: @doc,
        name: @name,
        path: @path,
        comment: @comment,
        end_pos: @end_pos,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(ImportSpec) && @doc === other.doc && @name === other.name &&
        @path === other.path && @comment === other.comment &&
        @end_pos === other.end_pos
    end
  end
  class ValueSpec < Node
    attr_reader(:doc, :names, :type, :values, :comment, :location, :comments)
    def initialize(
      doc: nil,
      names: [],
      type: nil,
      values: [],
      comment: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @doc = doc
      @names = names
      @type = type
      @values = values
      @comment = comment
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_value_spec(self)
    end
    def child_nodes
      [@doc, @names, @type, @values, @comment].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        doc: @doc,
        names: @names,
        type: @type,
        values: @values,
        comment: @comment,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(ValueSpec) && @doc === other.doc && @names === other.names &&
        @type === other.type && @values === other.values &&
        @comment === other.comment
    end
  end
  class TypeSpec < Node
    attr_reader(
      :doc,
      :name,
      :type_params,
      :assign,
      :type,
      :comment,
      :location,
      :comments
    )
    def initialize(
      doc: nil,
      name: nil,
      type_params: nil,
      assign: nil,
      type: nil,
      comment: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @doc = doc
      @name = name
      @type_params = type_params
      @assign = assign
      @type = type
      @comment = comment
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_type_spec(self)
    end
    def child_nodes
      [@doc, @name, @type_params, @type, @comment].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        doc: @doc,
        name: @name,
        type_params: @type_params,
        assign: @assign,
        type: @type,
        comment: @comment,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(TypeSpec) && @doc === other.doc && @name === other.name &&
        @type_params === other.type_params && @assign === other.assign &&
        @type === other.type && @comment === other.comment
    end
  end
  class BadDecl < Node
    attr_reader(:from, :to, :location, :comments)
    def initialize(
      from: nil,
      to: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @from = from
      @to = to
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_bad_decl(self)
    end
    def child_nodes
      []
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      { from: @from, to: @to, location: @location, comments: @comments }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(BadDecl) && @from === other.from && @to === other.to
    end
  end
  class GenDecl < Node
    attr_reader(
      :doc,
      :tok_pos,
      :tok,
      :lparen,
      :specs,
      :rparen,
      :location,
      :comments
    )
    def initialize(
      doc: nil,
      tok_pos: nil,
      tok: nil,
      lparen: nil,
      specs: [],
      rparen: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @doc = doc
      @tok_pos = tok_pos
      @tok = tok
      @lparen = lparen
      @specs = specs
      @rparen = rparen
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_gen_decl(self)
    end
    def child_nodes
      [@doc, @specs].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        doc: @doc,
        tok_pos: @tok_pos,
        tok: @tok,
        lparen: @lparen,
        specs: @specs,
        rparen: @rparen,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(GenDecl) && @doc === other.doc &&
        @tok_pos === other.tok_pos && @tok === other.tok &&
        @lparen === other.lparen && @specs === other.specs &&
        @rparen === other.rparen
    end
  end
  class FuncDecl < Node
    attr_reader(:doc, :recv, :name, :type, :body, :location, :comments)
    def initialize(
      doc: nil,
      recv: nil,
      name: nil,
      type: nil,
      body: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @doc = doc
      @recv = recv
      @name = name
      @type = type
      @body = body
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_func_decl(self)
    end
    def child_nodes
      [@doc, @recv, @name, @type, @body].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        doc: @doc,
        recv: @recv,
        name: @name,
        type: @type,
        body: @body,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(FuncDecl) && @doc === other.doc && @recv === other.recv &&
        @name === other.name && @type === other.type && @body === other.body
    end
  end
  class File < Node
    attr_reader(
      :doc,
      :package,
      :name,
      :decls,
      :file_start,
      :file_end,
      :scope,
      :imports,
      :unresolved,
      :comments,
      :go_version,
      :location
    )
    def initialize(
      doc: nil,
      package: nil,
      name: nil,
      decls: [],
      file_start: nil,
      file_end: nil,
      scope: nil,
      imports: [],
      unresolved: [],
      comments: [],
      go_version: nil,
      location: SyntaxTree::Location.default
    )
      @doc = doc
      @package = package
      @name = name
      @decls = decls
      @file_start = file_start
      @file_end = file_end
      @scope = scope
      @imports = imports
      @unresolved = unresolved
      @comments = comments
      @go_version = go_version
      @location = location
    end
    def accept(visitor)
      visitor.visit_file(self)
    end
    def child_nodes
      [@doc, @name, @decls, @imports, @unresolved, @comments].compact
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        doc: @doc,
        package: @package,
        name: @name,
        decls: @decls,
        file_start: @file_start,
        file_end: @file_end,
        scope: @scope,
        imports: @imports,
        unresolved: @unresolved,
        comments: @comments,
        go_version: @go_version,
        location: @location
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(File) && @doc === other.doc && @package === other.package &&
        @name === other.name && @decls === other.decls &&
        @file_start === other.file_start && @file_end === other.file_end &&
        @scope === other.scope && @imports === other.imports &&
        @unresolved === other.unresolved && @comments === other.comments &&
        @go_version === other.go_version
    end
  end
  class Package < Node
    attr_reader(:name, :scope, :imports, :files, :location, :comments)
    def initialize(
      name: nil,
      scope: nil,
      imports: nil,
      files: nil,
      location: SyntaxTree::Location.default,
      comments: []
    )
      @name = name
      @scope = scope
      @imports = imports
      @files = files
      @location = location
      @comments = comments
    end
    def accept(visitor)
      visitor.visit_package(self)
    end
    def child_nodes
      []
    end
    alias deconstruct child_nodes
    def deconstruct_keys(_keys)
      {
        name: @name,
        scope: @scope,
        imports: @imports,
        files: @files,
        location: @location,
        comments: @comments
      }
    end
    def format(q)
      Format.new(q).visit(self)
    end
    def ===(other)
      other.is_a?(Package) && @name === other.name && @scope === other.scope &&
        @imports === other.imports && @files === other.files
    end
  end
end
