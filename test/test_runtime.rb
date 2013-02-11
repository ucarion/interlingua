require_relative 'test_helper'

class RuntimeTest < Interlingua::TestCase
  def setup
    @runtime = Interlingua::Runtime.new(
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

  def test_get_constant
    assert_not_nil @runtime.runtime["MyObject"]
  end
  
  def test_create_an_object
    assert_equal @runtime.runtime["MyObject"], @runtime.runtime["MyObject"].new.runtime_class
  end
  
  def test_create_an_object_mapped_to_ruby_value
    assert_equal 32, @runtime.runtime["MyNumber"].new_with_value(32).value
  end
  
  def test_lookup_method_in_class
    assert_not_nil @runtime.runtime["MyObject"].lookup("myprint", 1)
    assert_raise(RuntimeError) { @runtime.runtime["MyObject"].lookup("non-existant", 1337) }
  end
  
  def test_call_method
    # Mimic Object.new in the language
    object = @runtime.runtime["MyObject"].call("mynew")
    
    assert_equal @runtime.runtime["MyObject"], object.runtime_class # assert object is an Object
  end
  
  def test_a_class_is_a_class
    assert_equal @runtime.runtime["MyClass"], @runtime.runtime["MyNumber"].runtime_class
  end
end