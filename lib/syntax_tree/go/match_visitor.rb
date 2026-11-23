module SyntaxTree::Go
  class MatchVisitor < Visitor
    attr_reader(:q)
    def initialize(q)
      @q = q
    end
  end
end
