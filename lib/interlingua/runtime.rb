module Interlingua
  class Runtime
    attr_reader :runtime, :keywords

    def initialize(keywords)
      @keywords = keywords
      setup
    end

    def setup
      # Set the entire Runtime up.

      # Step 1: create Class
      the_runtime_class = RuntimeClass.new(@runtime, @keywords)

      # Step 2: Class.class = Class
      the_runtime_class.runtime_class = the_runtime_class

      # Step 3: create Object
      the_runtime_object = RuntimeClass.new(@runtime, @keywords)

      # Step 4: Object.class = Class
      the_runtime_object.runtime_class = the_runtime_class

      # Step 5: create the universal context, aka HRH "Runtime"
      @runtime = RuntimeContext.new(the_runtime_object.new)

      # Step 6: put Class and Object into Runtime
      @runtime[@keywords["class_name"]] = the_runtime_class
      @runtime[@keywords["object_name"]] = the_runtime_object

      # Step 7: Make the basic classes too
      @runtime[@keywords["true_name"]] = RuntimeClass.new(@runtime, @keywords)
      @runtime[@keywords["false_name"]] = RuntimeClass.new(@runtime, @keywords)
      @runtime[@keywords["nil_name"]] = RuntimeClass.new(@runtime, @keywords)
      @runtime[@keywords["string_name"]] = RuntimeClass.new(@runtime, @keywords)
      @runtime[@keywords["number_name"]] = RuntimeClass.new(@runtime, @keywords)

      # Step 8: true, false, and nil are instances of TrueClass, FalseClass, and NilClass
      @runtime[@keywords["true"]] = @runtime[@keywords["true_name"]].new_with_value(true)
      @runtime[@keywords["false"]] = @runtime[@keywords["false_name"]].new_with_value(false)
      @runtime[@keywords["nil"]] = @runtime[@keywords["nil_name"]].new_with_value(nil)

      def add_std_method(class_name, method_name, args = 0, &body)
        @runtime[class_name].methods[[method_name, args]] = body
      end

      def add_std_methods(class_name, methods)
        methods.each do |method|
          # puts "Creating method #{method[0]} w/ args #{method[1]}"
          @runtime[class_name].methods[[method[0], method[1]]] = method[2]
        end
      end

      # Step 9: add the new method to class to allow syntax like Object.new
      add_std_method(@keywords["class_name"], @keywords["new"], 0) do |receiver, args| 
        receiver.new
      end

      # Step 10: add the print method
      add_std_method(@keywords["object_name"], @keywords["print"], 1) do |receiver, args| 
        print args.first.value
        @runtime[@keywords["nil"]]
      end

      add_std_method(@keywords["object_name"], @keywords["println"], 1) do |receiver, args|
        puts args.first.value
        @runtime[@keywords["nil"]]
      end

      # Step 11: make the basic math operations
      add_std_methods(@keywords["number_name"], [
        ["+", 1, proc { |r, a| @runtime[@keywords["number_name"]].new_with_value(r.value + a.first.value) }],
        ["-", 1, proc { |r, a| @runtime[@keywords["number_name"]].new_with_value(r.value - a.first.value) }],
        ["*", 1, proc { |r, a| @runtime[@keywords["number_name"]].new_with_value(r.value * a.first.value) }],
        ["/", 1, proc { |r, a| @runtime[@keywords["number_name"]].new_with_value(r.value / a.first.value) }],
        ["%", 1, proc { |r, a| @runtime[@keywords["number_name"]].new_with_value(r.value % a.first.value) }],

        [">", 1, proc { |r, a| r.value > a.first.value ? @runtime[@keywords["true"]] : @runtime[@keywords["false"]] }],
        ["<", 1, proc { |r, a| r.value < a.first.value ? @runtime[@keywords["true"]] : @runtime[@keywords["false"]] }],
        [">=", 1, proc { |r, a| r.value >= a.first.value ? @runtime[@keywords["true"]] : @runtime[@keywords["false"]] }],
        ["<=", 1, proc { |r, a| r.value <= a.first.value ? @runtime[@keywords["true"]] : @runtime[@keywords["false"]] }],
        ["==", 1, proc { |r, a| r.value == a.first.value ? @runtime[@keywords["true"]] : @runtime[@keywords["false"]] }],
        ["!=", 1, proc { |r, a| r.value != a.first.value ? @runtime[@keywords["true"]] : @runtime[@keywords["false"]] }],
      ])

      # Step 12: add basic string methods
      add_std_methods(@keywords["string_name"], [
        ["+", 1, proc { |r, a| @runtime[@keywords["number_name"]].new_with_value(r.value + a.first.value) }],
        [@keywords["charAt"], 1, proc { |r, a| @runtime[@keywords["number_name"]].new_with_value(r.value[a.first.value]) }],
        [@keywords["length"], 0, proc { |r, a| @runtime[@keywords["number_name"]].new_with_value(r.value.size) }],
      ])
    end

    # Internal representation of an object. All objects have a class and a value.
    # A value is Ruby's representation of what an object really is.
    class RuntimeObject
      attr_accessor :runtime_class, :value

      # Create a new object
      def initialize(runtime_class, value = self)
        @runtime_class = runtime_class
        @value = value
      end

      # Call a method on an object by asking its class to call the method if it exists.
      def call(method, args = [])
        @runtime_class.lookup(method, args.length).call(self, args)
      end
    end

    # Class is-a Object, but Object has-a class. A class stores all the methods
    # available to members of that class.
    class RuntimeClass < RuntimeObject
      attr_reader :methods

      def initialize(runtime, keywords, superclass = nil)
        @runtime = runtime
        @keywords = keywords
        @methods = {}
        if superclass.nil? && @runtime
          superclass = @runtime[@keywords["object_name"]]
        end
        @superclass = superclass

        # When setting up the environment, it might be problematic to determine
        # a class's class. Objects require knowing what their class is, but
        # classes are an object too... the solution is to temporarily set class's
        # class to nil as we set everything up, then manually set class's class
        # to itself later.
        # Runtime is defined during the bootstrapping process; see runtime_boot.rb
        if @runtime
          super(@runtime[@keywords["class_name"]])
        else
          super(nil)
        end
      end

      # find a method or die trying -- the attempt at getting a superclass's
      # implementation is OOP.
      def lookup(method_name, args)
        # puts "Looking up method #{method_name} with #{args} arguments"
        if @methods[[method_name, args]]
          # puts "Found #{method_name} (#{args} args)"
          @methods[[method_name, args]]
        elsif @superclass
          @superclass.lookup(method_name, args)
        else
          raise "Method not found: #{method_name}"
        end
      end

      # create a new instance of this class
      def new
        new_with_value(nil)
      end

      # create a new instance of this class w/ built-in Ruby value
      def new_with_value(value)
        RuntimeObject.new(self, value)
      end
    end

    # Represents a method and can be "called"
    class RuntimeMethod

      # corresponds to something like
      #
      # function(params) { body }
      def initialize(params, body, runtime, keywords)
        @params, @body, @runtime, @keywords = params, body, runtime, keywords
      end

      # corresponds to receiver.method(args)
      def call(receiver, args)
        # create a new context for this method to be evaluated as
        context = RuntimeContext.new(receiver)

        # set context's local variables
        @params.each_with_index do |param, index|
          context.locals[param] = args[index]
        end

        @body.eval(context, @runtime, @keywords)
      end
    end

    # Takes care of keeping track of local and constant variables, the current value
    # of self, and the current class being worked on.
    class RuntimeContext
      attr_reader :locals, :curr_self, :curr_class

      @@constants = {}

      def initialize(curr_self, curr_class = curr_self.runtime_class)
        @locals = {}
        @curr_self = curr_self
        @curr_class = curr_class
      end

      # shorthand methods to replace Runtime.constans["..."] w/ @runtime["..."]
      def [](constant)
        @@constants[constant]
      end

      def []=(constant, value)
        @@constants[constant] = value
      end
    end
  end
end