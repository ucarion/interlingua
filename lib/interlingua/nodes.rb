module Interlingua
  # Collection of nodes each one representing an expression.
  class Nodes < Struct.new(:nodes)
    attr_accessor :nodes

    def initialize(nodes)
      @nodes = nodes
    end
    
    def <<(node)
      @nodes << node
      self
    end

    def eval(context, runtime, keywords)
      return_val = nil
      nodes.each do |node|
        return_val = node.eval(context, runtime, keywords)
      end
      return_val || runtime[keywords["nil"]]
    end
  end

  # Literals are static values that have a Ruby representation, eg.: a string, a number, 
  # true, false, nil, etc.
  class LiteralNode
    attr_accessor :value

    def initialize(value)
      @value = value
    end
  end

  class NumberNode < LiteralNode
    def eval(context, runtime, keywords)
      runtime[keywords["number_name"]].new_with_value(@value)
    end
  end
  
  class StringNode < LiteralNode
    def eval(context, runtime, keywords)
      runtime[keywords["string_name"]].new_with_value(@value)
    end
  end

  class TrueNode < LiteralNode
    def initialize
      super(true)
    end

    def eval(context, runtime, keywords)
      runtime[keywords["true"]]
    end
  end

  class FalseNode < LiteralNode
    def initialize
      super(false)
    end

    def eval(context, runtime, keywords)
      runtime[keywords["false"]]
    end
  end

  class NilNode < LiteralNode
    def initialize
      super(nil)
    end

    def eval(context, runtime, keywords)
      runtime[keywords["nil"]]
    end
  end

  # Node of a method call or local variable access, can take any of these forms:
  # 
  #   method # this form can also be a local variable
  #   method(argument1, argument2)
  #   receiver.method
  #   receiver.method(argument1, argument2)
  #
  class CallNode
    attr_accessor :receiver, :method, :arguments

    def initialize(receiver, method, arguments)
      @receiver, @method, @arguments = receiver, method, arguments
    end

    def eval(context, runtime, keywords)
      if receiver.nil? && context.locals[method] && arguments.empty?
        context.locals[method]
      else # method call, plain and simple
        if receiver
          value = receiver.eval(context, runtime, keywords)
        else
          value = context.curr_self
        end

        eval_args = arguments.map { |arg| arg.eval(context, runtime, keywords) }
        value.call(method, eval_args)
      end
    end
  end

  # Retrieving the value of a constant.
  class GetConstantNode 
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def eval(context, runtime, keywords)
      context[name]
    end
  end

  # Setting the value of a constant.
  class SetConstantNode 
    attr_accessor :name, :value

    def initialize(name, value)
      @name, @value = name, value
    end

    def eval(context, runtime, keywords)
      context[name] = value.eval(context, runtime, keywords)
    end
  end

  # Setting the value of a local variable.
  class SetLocalNode
    attr_accessor :name, :value

    def initialize(name, value)
      @name, @value = name, value
    end

    def eval(context, runtime, keywords)
      context.locals[name] = value.eval(context, runtime, keywords)
    end
  end

  # Method definition.
  class DefNode
    attr_accessor :name, :params, :body

    def initialize(name, params, body)
      @name, @params, @body = name, params, body
    end

    def eval(context, runtime, keywords)
      context.curr_class.methods[[name, params.size]] = Interlingua::Runtime::RuntimeMethod.new(params, body, runtime, keywords)
    end
  end

  # Class definition.
  class ClassNode
    attr_accessor :name, :body

    def initialize(name, body)
      @name, @body = name, body
    end

    def eval(context, runtime, keywords)
      # try to re-open the class by seeing if it exists already
      target_class = context[name]

      unless target_class # so it doesn't exist, let's create it
        context[name] = target_class = Interlingua::Runtime::RuntimeClass.new(runtime, keywords)
      end

      # the new method has access to the context of the modified class
      contx = Interlingua::Runtime::RuntimeContext.new(target_class, target_class)
      body.eval(contx, contx, keywords)

      target_class
    end
  end

  # "if" control structure. Look at this node if you want to implement other control
  # structures like while, for, loop, etc.
  class IfNode
    attr_accessor :condition, :body

    def initialize(condition, body)
      @condition, @body = condition, body
    end

    def eval(context, runtime, keywords)
      if condition.eval(context, runtime, keywords).value
        body.eval(context, runtime, keywords)
      end
    end
  end

  # unless
  class UnlessNode
    attr_accessor :condition, :body

    def initialize(condition, body)
      @condition, @body = condition, body
    end

    def eval(context, runtime, keywords)
      unless condition.eval(context, runtime, keywords).value
        body.eval(context, runtime, keywords)
      end
    end
  end

  # while loop
  class WhileNode
    attr_accessor :condition, :body

    def initialize(condition, body)
      @condition, @body = condition, body
    end

    def eval(context, runtime, keywords)
      unless condition.eval(context, runtime, keywords).value
        body.eval(context, runtime, keywords)
      end
    end
  end

  # until loop
  class UntilNode
    attr_accessor :condition, :body

    def initialize(condition, body)
      @condition, @body = condition, body
    end

    def eval(context, runtime, keywords)
      unless condition.eval(context, runtime, keywords).value
        body.eval(context, runtime, keywords)
      end
    end
  end
end