require_relative 'test_helper'

class TestLexer < Interlingua::TestCase
  def setup
    @lexer = Interlingua::Lexer.new(
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
    assert_equal [[:NUMBER, 1]], @lexer.tokenize("1")
  end

  def test_string
    assert_equal [[:STRING, "one"]], @lexer.tokenize('"one"')
  end

  def test_boolean
    assert_equal [[:TRUE, "true"]], @lexer.tokenize("mytrue")
  end

  def test_normal_keywords_inactive
    code = <<-CODE
myif 3:
  unless 3
CODE
    tokens = [
      [:IF, "if"], [:NUMBER, 3],
        [:INDENT, 2],
        [:IDENTIFIER, "unless"], [:NUMBER, 3],
        [:DEDENT, 0]
    ]
    assert_equal tokens, @lexer.tokenize(code)
  end

  def test_indent
    code = <<-CODE
myif 1:
  myif 2:
    print "..."
    myif myfalse:
      pass
    print "done!"
  2

print "The End"
CODE
    tokens = [
      [:IF, "if"], [:NUMBER, 1],
        [:INDENT, 2],
          [:IF, "if"], [:NUMBER, 2],
          [:INDENT, 4],
            [:IDENTIFIER, "print"], [:STRING, "..."], [:NEWLINE, "\n"],
            [:IF, "if"], [:FALSE, "false"],
            [:INDENT, 6],
              [:IDENTIFIER, "pass"],
            [:DEDENT, 4], [:NEWLINE, "\n"],
            [:IDENTIFIER, "print"], [:STRING, "done!"],
        [:DEDENT, 2], [:NEWLINE, "\n"],
        [:NUMBER, 2],
      [:DEDENT, 0], [:NEWLINE, "\n"],
      [:NEWLINE, "\n"],
      [:IDENTIFIER, "print"], [:STRING, "The End"]
    ]
    assert_equal tokens, @lexer.tokenize(code)
  end
end