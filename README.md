# Interlingua #

Interlingua is a programming language where the keywords are set by the user. It's based on [ulyssescript](https://github.com/ulyssecarion/ulyssescript), another programming language I made.

I made this with the idea that those who want to learn a computer programming language but do not speak English. Though it has become the status quo of computer science that all major programming languages must be in English, this doesn't mean that people who just want to try programming out have to learn English words.

On top of that, I thought it would be cool if I could make my own flavor of [LOLCODE](http://en.wikipedia.org/wiki/LOLCODE).

# How to use #

You can make a new interpreter by specifying what you want your keywords to be. For instance, if you wanted to create a programming language that read like French, you could do it as:

```ruby
interpreter = Interlingua::Interpreter.new(
        "def" => "defini",
        "class" => "classe",
        "if" => "si",
        "unless" => "saufsi",
        "while" => "pendantque",
        "until" => "jusquaque",
        "class_name" => "Classe",
        "object_name" => "Objet",
        "true_name" => "ClasseVrai",
        "false_name" => "ClasseFaux",
        "nil_name" => "ClasseNul",
        "string_name" => "ChaineCharacteres",
        "number_name" => "Numero",
        "true" => "vrai",
        "false" => "faux",
        "nil" => "nul",
        "new" => "nouveau",
        "print" => "imprime",
        "println" => "imprimeall", # short for "imprime a-la-ligne"
        "charAt" => "charA",
        "length" => "longeur"
      )
```

And then you could create a file that is programmed using your newly defined keywords and classes:

```python
classe Toto:
  defini bonjour_monde:
    "Bonjour, monde!"
    
t = Toto.nouveau
imprime(t.bonjour_monde())
```

Then you can do

```ruby
interpreter.interpret( # your code as a string # )
```

to execute this code.
