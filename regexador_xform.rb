require 'parslet'

abort "Require out of order" if ! defined? Regexador

class Regexador::Transform < Parslet::Transform

  class Node  # a general-purpose tree node
    def initialize(hash = {})
      hash.each do |name, value|
        self.class_eval { attr_accessor name }
        self.send("#{name}=", value.to_s)
      end
    end
  
    def method_missing(meth, *args)
      if args.empty?
        instance_variable_get("@" + meth.to_s)
      elsif args.size == 1 and meth.to_s[-1..-1] == "="
        instance_variable_set("@" + meth.to_s[0..-2], args.first)
      else
        raise "No such method '#{meth}'"
      end
    end
  end
  
  class Pattern < Node
    def to_regex
      raise "Never overridden"
    end

    def to_str
      to_regex
    end

    def to_s
      to_regex
    end

    def inspect
       to_regex  # "#{self.class}:(#{to_regex}) "
    end
  end

  class Char < Pattern
    def to_regex
      @char
    end
  end
  
  class Range < Pattern
    def to_regex
      "[#@c1-#@c2]"
    end
  end
  
  class NegatedRange < Range
    def to_regex
      "[^#@nr1-#@nr2]"
    end
  end

  class NegatedChar < Pattern  # more like a range really
    def to_regex
      "[^#@nchar]"
    end
  end
  
  class POSIXClass < Pattern
    def to_regex
      "[[:#@pclass:]]"
    end
  end

  class CharClass < Pattern
    def to_regex
      "[#@char_class]"
    end
  end

  class NegatedClass < Pattern
    def to_regex
      "[^#@neg_class]"
    end
  end

  class Predefined < Pattern
    def to_regex
      case @pre.to_sym
        when :pBOS then "^"
        when :pEOS then "$"
        when :pWB  then "\\b"
      else
        raise "#@pre is not handled yet"
      end
    end
  end

  class StringNode < Pattern
    def to_regex
      @string
    end
  end

  class Repeat1 < Pattern
    def to_regex
      "(#@match_item){#@num1}"
    end
  end

  class Repeat2 < Pattern
    def to_regex
      "(#@match_item){#@num1,#@num2}"
    end
  end

  class Any < Pattern
    def to_regex
      "(#@match_item)*"
    end
  end

  class Many < Pattern
    def to_regex
      "(#@match_item)+"
    end
  end

  class Maybe < Pattern
    def to_regex
      "(#@match_item)?"
    end
  end


  # Actual transformation rules

  rule(:char => simple(:char))    { Char.new(char: char) }
  rule(:c1 => simple(:c1), :c2 => simple(:c2)) { Range.new(c1: c1, c2: c2) }

  rule(:nr1 => simple(:nr1), :nr2 => simple(:nr2)) { NegatedRange.new(nr1: nr1, nr2: nr2) }
  rule(:nchar => simple(:nchar))  { NegatedChar.new(nchar: nchar) } # Don't forget escaping

  rule(:pclass => simple(:pclass)) { POSIXClass.new(pclass: pclass) }

  rule(:char_class => simple(:char_class)) { CharClass.new(char_class: char_class) }
  rule(:neg_class => simple(:neg_class))   { NegatedClass.new(neg_class: neg_class) }

  rule(:bos => simple(:pBOS)) { Predefined.new(pre: :pBOS) }   # How to simplify these?
  rule(:eos => simple(:pEOS)) { Predefined.new(pre: :pEOS) } 
  rule(:wb  => simple(:pWB))  { Predefined.new(pre: :pWB) }

  rule(:string => simple(:string))  { StringNode.new(string: string) }

  rule(:num1 => simple(:num1), :match_item => simple(:match_item)) { Repeat1.new(num1: num1, match_item: match_item) }
  
  rule(:num1 => simple(:num1), :num2 => simple(:num2), :match_item => simple(:match_item)) { Repeat2.new(num1: num1, num2: num2, match_item: match_item) }


  rule(:qualifier => simple(:qualifier), :match_item => simple(:match_item)) do
    case qualifier 
      when Regexador::Parser::ANY
        Any.new(match_item: match_item)
      when Regexador::Parser::MANY
        Many.new(match_item: match_item)
      when Regexador::Parser::MAYBE
        Maybe.new(match_item: match_item)
    end
  end
end

