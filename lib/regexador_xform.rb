require 'parslet'

abort "Require out of order" if ! defined? Regexador

class Regexador::Transform < Parslet::Transform
  class Node
    def self.make(*fields, &block)
      klass = ::Class.new(self) do
        fields.each {|field| attr_accessor field }
        define_method(:fields) { fields.dup }
        define_method(:to_s, &block)
      end
      klass
    end

    def initialize *values
      fields.zip(values) { |f,v| self.send("#{f}=", v) }
    end

    def to_s
      raise NotImplementedError, 
            "Please implement #to_s for #{short_name}."
    end

    def to_str
      to_s
    end

    def short_name
      str = self.class.name
      str[str.rindex('::')+2..-1]
    end

    def inspect
      data = fields.map {|f| "#{f}=#{self.send(f).inspect}" }.join(', ')
      short_name + "(" + data + ")"
    end
  end

  # Later: Remember escaping for chars (char, c1, c2, nchar, ...)

  XChar        = Node.make(:char)       { char == '\\' ? "\\\\" : char.to_s }
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

  StringNode = Node.make(:string)                   { string.to_s }
  Repeat1    = Node.make(:num1, :match_item)        { "(#@match_item){#@num1}" }
  Repeat2    = Node.make(:num1, :num2, :match_item) { "(#@match_item){#@num1,#@num2}" }
  Any        = Node.make(:match_item)               { "(#@match_item)*" }
  Many       = Node.make(:match_item)               { "(#@match_item)+" }
  Maybe      = Node.make(:match_item)               { "(#@match_item)?" }

  Sequence    = Node.make(:elements) { elements.map(&:to_s).join }
  Alternation = Node.make(:elements) { '(' + elements.map(&:to_s).join('|') + ')' }

  Assign     = Node.make(:var, :rvalue)  { "" }  # Doesn't actually translate directly.
  Usage      = Node.make(:var) { 
    "var(#{var})" }
    #lookup(var) }

  Program    = Node.make(:definitions, :match) { 
    # definitions.each { |d| d.store }
    match.to_s }

  class Assign < Node    # For clarity: Really already is-a Node
    class << self
      attr_accessor :bindings
    end

    def store
      self.class.bindings ||= {}
      self.class.bindings[@var] = @rvalue.to_s
    end
  end

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
  # When the string is empty, parslet returns an empty array for lack of content. 
  # Map that to the empty string node.
  rule(:string => sequence(:string))  { StringNode.new('') }

  rule(:num1 => simple(:num1), :match_item => simple(:match_item)) { Repeat1.new(num1, match_item) }
  
  rule(:num1 => simple(:num1), :num2 => simple(:num2), :match_item => simple(:match_item)) { Repeat2.new(num1, num2, match_item) }

  rule(:qualifier => 'any',   :match_item => simple(:match_item)) { Any.new(match_item) }
  rule(:qualifier => 'many',  :match_item => simple(:match_item)) { Many.new(match_item) }
  rule(:qualifier => 'maybe', :match_item => simple(:match_item)) { Maybe.new(match_item) }

  rule(:var => simple(:var), :rvalue => simple(:rvalue)) { Assign.new(@var, @rvalue) }

  rule(:alternation => simple(:pattern))        { pattern }
  rule(:alternation => sequence(:alternatives)) { Alternation.new(alternatives) }

  rule(:sequence => simple(:element))    { element }
  rule(:sequence => sequence(:elements)) { Sequence.new(elements) }
  
  rule(:var => simple(:name)) { Usage.new(name) }

  rule(:definitions => sequence(:definitions), :match => simple(:match)) {
    Program.new(definitions, match) }
end

