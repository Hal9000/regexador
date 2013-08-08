require 'parslet'

abort "Require out of order" if ! defined? Regexador

class Regexador::Transform < Parslet::Transform

  class Node < BasicObject
    def self.make(*fields, &block)
      klass = ::Class.new
      klass.class_eval do
        fields.each {|field| attr_accessor field }
        define_method :initialize do |*values|
          fields.zip(values) {|f,v| self.send("#{f}=", v) }
        end
        define_method(:to_regex) { instance_eval(&block) }
        define_method(:to_str)   { to_regex }
        define_method(:to_s)     { to_regex }
        define_method(:inspect)  { to_regex }
      end
      klass
    end
  end

  # Later: Remember escaping for chars (char, c1, c2, nchar, ...)

  XChar        = Node.make(:char)       { "#@char" }
  CharRange    = Node.make(:c1, :c2)    { "[#@c1-#@c2]" }
  NegatedRange = Node.make(:nr1, :nr2)  { "[^#@nr1-#@nr2]" }
  NegatedChar  = Node.make(:nchar)      { "[^#@nchar]" }    # More like a range really
  POSIXClass   = Node.make(:pclass)     { "[[:#@pclass:]]" }
  CharClass    = Node.make(:char_class) { "[#@char_class]" }
  NegatedClass = Node.make(:neg_class)  { "[^#@neg_class]" }
  Predefined   = Node.make(:pre) do 
    sym = "p#@pre".to_sym
    str = Regexador::Parser::Predef2Regex[sym]
    raise "#@pre is not handled yet" if str.nil?
    str
  end

  StringNode = Node.make(:string)                   { "#@string" }
  Repeat1    = Node.make(:num1, :match_item)        { "(#@match_item){#@num1}" }
  Repeat2    = Node.make(:num1, :num2, :match_item) { "(#@match_item){#@num1,#@num2}" }
  Any        = Node.make(:match_item)               { "(#@match_item)*" }
  Many       = Node.make(:match_item)               { "(#@match_item)+" }
  Maybe      = Node.make(:match_item)               { "(#@match_item)?" }

# exit

  # Actual transformation rules

  rule(:char => simple(:ch))    { XChar.new(ch) }
  rule(:c1 => simple(:c1), :c2 => simple(:c2)) { CharRange.new(c1, c2) }

  rule(:nr1 => simple(:nr1), :nr2 => simple(:nr2)) { NegatedRange.new(nr1, nr2) }
  rule(:nchar => simple(:nchar))  { NegatedChar.new(nchar) } # Don't forget escaping

  rule(:pclass => simple(:pclass)) { POSIXClass.new(pclass) }

  rule(:char_class => simple(:char_class)) { CharClass.new(char_class) }
  rule(:neg_class => simple(:neg_class))   { NegatedClass.new(neg_class) }

  rule(:predef => simple(:content)) { Predefined.new(content) }

  rule(:string => simple(:string))  { StringNode.new(string) }

  rule(:num1 => simple(:num1), :match_item => simple(:match_item)) { Repeat1.new(num1, match_item) }
  
  rule(:num1 => simple(:num1), :num2 => simple(:num2), :match_item => simple(:match_item)) { Repeat2.new(num1, num2, match_item) }


  rule(:qualifier => 'any',   :match_item => simple(:match_item)) { Any.new(match_item) }
  rule(:qualifier => 'many',  :match_item => simple(:match_item)) { Many.new(match_item) }
  rule(:qualifier => 'maybe', :match_item => simple(:match_item)) { Maybe.new(match_item) }

end

