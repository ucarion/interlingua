module Interlingua
  class Interpreter
    def initialize(keywords)
      @keywords = keywords
      @parser = Interlingua::Parser.new(keywords)
    end

    def interpret(code)
      runtime = Interlingua::Runtime.new(@keywords)
      @parser.parse(code).eval(runtime.runtime, @keywords)
    end
  end
end