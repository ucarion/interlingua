class Parser

# Declare tokens produced by the lexer
token IF ELSE
token UNLESS
token WHILE
token UNTIL
token DEF
token CLASS
token NEWLINE
token NUMBER
token STRING
token TRUE FALSE NIL
token IDENTIFIER
token CONSTANT
token INDENT DEDENT

# Precedence table
# Based on http://en.wikipedia.org/wiki/Operators_in_C_and_C%2B%2B#Operator_precedence
prechigh
  left  '.'
  right '!'
  left  '*' '/' '%'
  left  '+' '-'
  left  '>' '>=' '<' '<='
  left  '==' '!='
  left  '&&'
  left  '||'
  right '='
  left  ','
preclow

rule
  # All rules are declared in this format:
  #
  #   RuleName:
  #     OtherRule TOKEN AnotherRule    { code to run when this matches }
  #   | OtherRule                      { ... }
  #   ;
  #
  # In the code section (inside the {...} on the right):
  # - Assign to "result" the value returned by the rule.
  # - Use val[index of expression] to reference expressions on the left.
  
  
  # All parsing will end in this rule, being the trunk of the AST.
  Root:
    /* nothing */                      { result = Interlingua::Nodes.new([]) }
  | Expressions                        { result = val[0] }
  ;
  
  # Any list of expressions, class or method body, separated by line breaks.
  Expressions:
    Expression                         { result = Interlingua::Nodes.new(val) }
  | Expressions Terminator Expression  { result = val[0] << val[2] }
    # To ignore trailing line breaks
  | Expressions Terminator             { result = val[0] }
  | Terminator                         { result = Interlingua::Nodes.new([]) }
  ;

  # All types of expressions in our language
  Expression:
    Literal
  | Call
  | Operator
  | Constant
  | Assign
  | Def
  | Class
  | If
  | Unless
  | While
  | Until
  | '(' Expression ')'    { result = val[1] }
  ;
  
  # All tokens that can terminate an expression
  Terminator:
    NEWLINE
  | ";"
  ;
  
  # All hard-coded values
  Literal:
    NUMBER                        { result = Interlingua::NumberNode.new(val[0]) }
  | STRING                        { result = Interlingua::StringNode.new(val[0]) }
  | TRUE                          { result = Interlingua::TrueNode.new }
  | FALSE                         { result = Interlingua::FalseNode.new }
  | NIL                           { result = Interlingua::NilNode.new }
  ;
  
  # A method call
  Call:
    # method
    IDENTIFIER                    { result = Interlingua::CallNode.new(nil, val[0], []) }
    # method(arguments)
  | IDENTIFIER "(" ArgList ")"    { result = Interlingua::CallNode.new(nil, val[0], val[2]) }
    # receiver.method
  | Expression "." IDENTIFIER     { result = Interlingua::CallNode.new(val[0], val[2], []) }
    # receiver.method(arguments)
  | Expression "."
      IDENTIFIER "(" ArgList ")"  { result = Interlingua::CallNode.new(val[0], val[2], val[4]) }
  ;
  
  ArgList:
    /* nothing */                 { result = [] }
  | Expression                    { result = val }
  | ArgList "," Expression        { result = val[0] << val[2] }
  ;
  
  Operator:
  # Binary operators
    Expression '||' Expression    { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '&&' Expression    { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '==' Expression    { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '!=' Expression    { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>' Expression     { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '>=' Expression    { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<' Expression     { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '<=' Expression    { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '+' Expression     { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '-' Expression     { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '*' Expression     { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '/' Expression     { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | Expression '%' Expression     { result = Interlingua::CallNode.new(val[0], val[1], [val[2]]) }
  | '!' Expression                { result = Interlingua::CallNode.new(val[1], val[0], []) }
  ;
  
  Constant:
    CONSTANT                      { result = Interlingua::GetConstantNode.new(val[0]) }
  ;
  
  # Assignment to a variable or constant
  Assign:
    IDENTIFIER "=" Expression     { result = Interlingua::SetLocalNode.new(val[0], val[2]) }
  | CONSTANT "=" Expression       { result = Interlingua::SetConstantNode.new(val[0], val[2]) }
  ;
  
  # Method definition
  Def:
    DEF IDENTIFIER Block          { result = Interlingua::DefNode.new(val[1], [], val[2]) }
  | DEF IDENTIFIER
      "(" ParamList ")" Block     { result = Interlingua::DefNode.new(val[1], val[3], val[5]) }
  ;

  ParamList:
    /* nothing */                 { result = [] }
  | IDENTIFIER                    { result = val }
  | ParamList "," IDENTIFIER      { result = val[0] << val[2] }
  ;
  
  # Class definition
  Class:
    CLASS CONSTANT Block          { result = Interlingua::ClassNode.new(val[1], val[2]) }
  ;
  
  # if block
  If:
    IF Expression Block           { result = Interlingua::IfNode.new(val[1], val[2]) }
  ;
  
  # unless block
  Unless:
    UNLESS Expression Block       { result = Interlingua::UnlessNode.new(val[1], val[2]) }
  ;

  # while loop
  While:
    WHILE Expression Block        { result = Interlingua::WhileNode.new(val[1], val[2]) }
  ;

  # until loop
  Until:
    UNTIL Expression Block        { result = Interlingua::UntilNode.new(val[1], val[2]) }
  ;

  # A block of indented code. You see here that all the hard work was done by the
  # lexer.
  Block:
    INDENT Expressions DEDENT     { result = val[1] }
  # If you don't like indentation you could replace the previous rule with the 
  # following one to separate blocks w/ curly brackets. You'll also need to remove the
  # indentation magic section in the lexer.
  # "{" Expressions "}"           { replace = val[1] }
  ;
end

---- header

---- inner
  # This code will be put as-is in the Parser class.
  def parse(code, show_tokens=false)
    @tokens = Interlingua::Lexer.new.tokenize(code) # Tokenize the code using our lexer
    puts @tokens.inspect if show_tokens
    do_parse # Kickoff the parsing process
  end
  
  def next_token
    @tokens.shift
  end