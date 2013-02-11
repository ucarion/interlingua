require_relative 'test_helper'

class InterpreterTest < Interlingua::TestCase
  def setup
    @interpreter = Interlingua::Interpreter.new(
        "def" => "mydef",
        "class" => "myclass",
        "if" => "myif",
        "unless" => "myunless",
        "while" => "mywhile",
        "until" => "myuntil",
        "class_name" => "MyClass",
        "object_name" => "MyObject",
        "true_name" => "MyTrueClass",
        "false_name" => "MyFalseClass",
        "nil_name" => "MyNilClass",
        "string_name" => "MyString",
        "number_name" => "MyNumber",
        "true" => "mytrue",
        "false" => "myfalse",
        "nil" => "mynil",
        "new" => "mynew",
        "print" => "myprint",
        "println" => "myprintln",
        "charAt" => "mycharAt",
        "length" => "mylength"
      )
  end

  def test_number
    assert_equal 1, @interpreter.interpret("1").value
  end
  
  def test_true
    assert_equal true, @interpreter.interpret("mytrue").value
  end
  
  def test_assign
    assert_equal 2, @interpreter.interpret("a = 2; 3; a").value
  end
  
  def test_method
    code = <<-CODE
mydef boo(a):
  a

boo("yah!")
CODE
    
    assert_equal "yah!", @interpreter.interpret(code).value
  end
  
  def test_reopen_class
    code = <<-CODE
myclass MyNumber:
  mydef ten:
    10

1.ten
CODE
    
    assert_equal 10, @interpreter.interpret(code).value
  end
  
  def test_define_class
    code = <<-CODE
myclass Pony:
  mydef awesome:
    mytrue

Pony.mynew.awesome
CODE
    
    assert_equal true, @interpreter.interpret(code).value
  end
  
  def test_if
    code = <<-CODE
myif mytrue:
  "works!"
CODE
    
    assert_equal "works!", @interpreter.interpret(code).value
  end
  
  def test_interpret
    code = <<-CODE
myclass Awesome:
  mydef does_it_work:
    "yeah!"

awesome_object = Awesome.mynew
awesome_object.does_it_work
CODE
    
    assert_equal "yeah!", @interpreter.interpret(code).value
  end

  def test_math_operators
    assert_equal 3, @interpreter.interpret("1 + 2").value
    assert_equal 5, @interpreter.interpret("6 - 1").value
    assert_equal 42, @interpreter.interpret("6 * 7").value
    assert_equal 2, @interpreter.interpret("5 / 2").value
    assert_equal 6, @interpreter.interpret("16 % 10").value
    assert @interpreter.interpret("2 > 1").value
    assert !@interpreter.interpret("1 > 2").value
    assert @interpreter.interpret("1 < 2").value
    assert !@interpreter.interpret("2 < 1").value
    assert @interpreter.interpret("1 >= 1").value
    assert @interpreter.interpret("1 <= 1").value
    assert @interpreter.interpret("1 == 1").value
    assert !@interpreter.interpret("1 == 2").value
    assert @interpreter.interpret("1 != 2").value
    assert !@interpreter.interpret("1 != 1").value
  end

  def test_method_overriding
    code = <<-CODE
mydef foo():
  "no-args"

mydef foo(x):
  "yes-args"

foo(3)
CODE
    
    assert_equal "yes-args", @interpreter.interpret(code).value
  end

  def test_string_methods
    assert_equal "foobar", @interpreter.interpret('"foo" + "bar"').value
    assert_equal 4, @interpreter.interpret('"four".mylength').value
    assert_equal "a", @interpreter.interpret('"bat".mycharAt(1)').value
  end
end