module SyntaxTree::Go
  class PrettyPrintVisitor < Visitor
    attr_reader(:q)
    def initialize(q)
      @q = q
    end
  end
end
