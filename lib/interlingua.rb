require_relative 'interlingua/core'

module Interlingua
  DEFAULT_KEYWORDS = {
    "def" => "def",
    "class" => "class",
    "if" => "if",
    "unless" => "unless",
    "while" => "while",
    "until" => "until",
    "class_name" => "Class",
    "object_name" => "Object", 
    "true_name" => "TrueClass", 
    "false_name" => "FalseClass", 
    "nil_name" => "NilClass", 
    "string_name" => "String", 
    "number_name" => "Number", 
    "true" => "true", 
    "false" => "false", 
    "nil" => "nil", 
    "new" => "new", 
    "print" => "print", 
    "println" => "println", 
    "charAt" => "charAt", 
    "length" => "length"}

  def Interlingua.get_interpreter_for(keywords)
    validate_keywords(keywords)
    Interlingua::Interpreter.new(keywords)
  end

  private

    def Interlingua.validate_keywords(keywords)
      raise "Error: all keywords must be unique!" if keywords.values != keywords.values.uniq
      DEFAULT_KEYWORDS.keys.each do |keyword|
        if !keywords[keyword] || keywords[keyword].empty?
          puts "Warning: missing or invalid keyword for #{keyword}; defaulting to #{DEFAULT_KEYWORDS[keyword]}."
          keywords[keyword] = DEFAULT_KEYWORDS[keyword]
        end
      end
    end
end