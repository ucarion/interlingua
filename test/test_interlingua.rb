require_relative 'test_helper'

class InterlinguaTest < Interlingua::TestCase
  def test_validates_for_repeated_keywords
    assert_raises(RuntimeError) { Interlingua.get_interpreter_for("if" => "xxx", "unless" => "xxx")}
  end
end