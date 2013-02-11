require_relative 'test_helper'

class ParserTest < Interlingua::TestCase
  def setup
    @parser = Interlingua::Parser.new(
        "def" => "mydef",
        "class" => "myclass",
        "if" => "myif",
        "unless" => "myunless",
        "while" => "mywhile",
        "until" => "myuntil",
        "true" => "mytrue",
        "false" => "myfalse",
        "nil" => "mynil"
      )
  end

  def test_number
    assert_equal Interlingua::Nodes.new([Interlingua::NumberNode.new(1)]), @parser.parse("1")
  end
  
  def test_expression
    assert_equal Interlingua::Nodes.new([Interlingua::NumberNode.new(1), Interlingua::StringNode.new("hi")]), @parser.parse(%{1\n"hi"})
  end
  
  def test_call
    assert_equal Interlingua::Nodes.new([Interlingua::CallNode.new(Interlingua::NumberNode.new(1), "method", [])]), @parser.parse("1.method")
  end
  
  def test_call_with_arguments
    assert_equal Interlingua::Nodes.new([Interlingua::CallNode.new(nil, "method", [Interlingua::NumberNode.new(1), Interlingua::NumberNode.new(2)])]), @parser.parse("method(1, 2)")
  end
  
  def test_assign
    assert_equal Interlingua::Nodes.new([Interlingua::SetLocalNode.new("a", Interlingua::NumberNode.new(1))]), @parser.parse("a = 1")
    assert_equal Interlingua::Nodes.new([Interlingua::SetConstantNode.new("A", Interlingua::NumberNode.new(1))]), @parser.parse("A = 1")
  end
  
  def test_def
    code = <<-CODE
mydef method:
  mytrue
CODE
    
    nodes = Interlingua::Nodes.new([
      Interlingua::DefNode.new("method", [],
        Interlingua::Nodes.new([Interlingua::TrueNode.new])
      )
    ])
    
    assert_equal nodes, @parser.parse(code)
  end
  
  def test_def_with_param
    code = <<-CODE
mydef method(a, b):
  mytrue
CODE
    
    nodes = Interlingua::Nodes.new([
      Interlingua::DefNode.new("method", ["a", "b"],
        Interlingua::Nodes.new([Interlingua::TrueNode.new])
      )
    ])
    
    assert_equal nodes, @parser.parse(code)
  end
  
  def test_class
    code = <<-CODE
myclass Muffin:
  mytrue
CODE
    
    nodes = Interlingua::Nodes.new([
      Interlingua::ClassNode.new("Muffin",
        Interlingua::Nodes.new([Interlingua::TrueNode.new])
      )
    ])
    
    assert_equal nodes, @parser.parse(code)
  end
  
  def test_arithmetic
    nodes = Interlingua::Nodes.new([
      Interlingua::CallNode.new(Interlingua::NumberNode.new(1), "+", [
        Interlingua::CallNode.new(Interlingua::NumberNode.new(2), "*", [Interlingua::NumberNode.new(3)])
      ])
    ])
    assert_equal nodes, @parser.parse("1 + 2 * 3")
    assert_equal nodes, @parser.parse("1 + (2 * 3)")
  end
  
  def test_binary_operator
    assert_equal Interlingua::Nodes.new([
      Interlingua::CallNode.new(
        Interlingua::CallNode.new(Interlingua::NumberNode.new(1), "+", [Interlingua::NumberNode.new(2)]),
        "||",
        [Interlingua::NumberNode.new(3)]
      )
    ]), @parser.parse("1 + 2 || 3")
  end
  
  ## Exercise: Add a grammar rule to handle the `!` unary operators
  # Remove the x in front of the method name to run.
  def test_unary_operator
    assert_equal Interlingua::Nodes.new([
      Interlingua::CallNode.new(Interlingua::NumberNode.new(2), "!", [])
    ]), @parser.parse("!2")
  end
  
  def test_if
    code = <<-CODE
myif mytrue:
  mynil
CODE
    
    nodes = Interlingua::Nodes.new([
      Interlingua::IfNode.new(Interlingua::TrueNode.new,
        Interlingua::Nodes.new([Interlingua::NilNode.new])
      )
    ])
    
    assert_equal nodes, @parser.parse(code)
  end

  def test_while
    code = <<-CODE
mywhile mytrue:
  mynil
CODE
    
    nodes = Interlingua::Nodes.new([
      Interlingua::WhileNode.new(Interlingua::TrueNode.new,
        Interlingua::Nodes.new([Interlingua::NilNode.new])
      )
    ])
    
    assert_equal nodes, @parser.parse(code)
  end

  def test_unless
    code = <<-CODE
myunless mytrue:
  mynil
CODE
    
    nodes = Interlingua::Nodes.new([
      Interlingua::UnlessNode.new(Interlingua::TrueNode.new,
        Interlingua::Nodes.new([Interlingua::NilNode.new])
      )
    ])
    
    assert_equal nodes, @parser.parse(code)
  end

   def test_until
    code = <<-CODE
myuntil mytrue:
  mynil
CODE
    
    nodes = Interlingua::Nodes.new([
      Interlingua::UntilNode.new(Interlingua::TrueNode.new,
        Interlingua::Nodes.new([Interlingua::NilNode.new])
      )
    ])
    
    assert_equal nodes, @parser.parse(code)
  end
end