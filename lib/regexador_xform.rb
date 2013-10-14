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
      fields.zip(values) {|f,v| self.send("#{f}=", v) }
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

  XChar        = Node.make(:char) do 
    Regexp.escape(char)
  end

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

  StringNode = Node.make(:string)                   { Regexp.escape(string.to_s) }
  Repeat1    = Node.make(:num1, :match_item)        { "(#@match_item){#@num1}" }
  Repeat2    = Node.make(:num1, :num2, :match_item) { "(#@match_item){#@num1,#@num2}" }
  Any        = Node.make(:match_item)               { "(#@match_item)*" }
  Many       = Node.make(:match_item)               { "(#@match_item)+" }
  Maybe      = Node.make(:match_item)               { "(#@match_item)?" }
  Nocase     = Node.make(:match_item)               { "((?i)#@match_item)" }

  FindWith   = Node.make(:findpat, :pospat)         { "((?=#@findpat#@pospat)#@findpat)" }
  FindWithout = Node.make(:findpat, :negpat)        { "((?!#@findpat#@negpat)#@findpat)" }
  WithFind   = Node.make(:pospat, :findpat)         { "((?<=#@pospat)#@findpat)" }
  WithoutFind = Node.make(:negpat, :findpat)        { "((?<!#@negpat)#@pospat)" }

  Within     = Node.make(:delim)                    { "(#@delim.*?#@delim)" }   # /x[^y]*?y/ 

  Sequence    = Node.make(:elements) { elements.map(&:to_s).join }
  Alternation = Node.make(:elements) { '(' + elements.map(&:to_s).join('|') + ')' }

  Assignment = Node.make(:var, :rvalue)  { "" }  # Doesn't actually translate directly.
  Usage      = Node.make(:var)           { Assignment.bindings[var.to_s].to_s }

  Program    = Node.make(:definitions, :match) do 
    # NOTE Since we're using to_s for conversion to regular expression, 
    # debugging cannot be done using string interpolation, otherwise we 
    # call things out of order just by debug-printing them! 
    # 
    # puts "In Program: #{match}"          # Don't do this
    # puts "In Program: #{match.inspect}"  # But this is OK
    definitions.each {|d| d.store }
    match.to_s 
  end

  class Assignment < Node    # For clarity: Really already is-a Node
    class << self
      attr_accessor :bindings
    end

    def store
      # puts "Storing #@var = #{@rvalue.inspect}"
      hash = self.class.bindings ||= {}

      hash[@var.to_s] = @rvalue          # Late binding
      # hash[@var.to_s] = @rvalue.to_s   # Early binding
      # Think about the difference... :)
    end
  end

  Captured = Node.make(:cname, :pattern) { "(?<#@cname>#@pattern)" }
  Backref = Node.make(:name) { "\\k<#@name>" }

  Parameter = Node.make(:param) { "(#{param}){0}" }

=begin
  find X with Y       # /(?=XY)X/     - pos lookahead
  find X without Y    # /(?!XY)X/     - neg lookahead
  with X find Y       # /(?<=X)Y/     - pos lookbehind
  without X find Y    # /(?<!X)Y/     - neg lookbehind
=end
  PosAhead  = Node.make(:pla1, :pla2)  { "(?=#@pla1#@pla2)#@pla1" }
  NegAhead  = Node.make(:nla1, :nla2)  { "(?!#@nla1#@nla2)#@nla1" }
  PosBehind = Node.make(:plb1, :plb2)  { "(?<=#@plb1)#@plb2" }
  NegBehind = Node.make(:nlb1, :nlb2)  { "(?<!#@nlb1)#@nlb2" }

  # Actual transformation rules

  rule(:char => simple(:ch))        { XChar.new(ch) }
  rule(:unicode => simple(:hex4))   { StringNode.new("" << Integer("0x#{hex4}")) }

  rule(:string => simple(:string))  { StringNode.new(string) }
  # When the string is empty, parslet returns an empty array for lack of content. 
  # Map that to the empty string node.
  rule(:string => sequence(:string))  { StringNode.new('') }

  rule(:c1 => simple(:c1), :c2 => simple(:c2)) { CharRange.new(c1, c2) }

  rule(:nr1 => simple(:nr1), :nr2 => simple(:nr2)) { NegatedRange.new(nr1, nr2) }
  rule(:nchar => simple(:nchar))  { NegatedChar.new(nchar) } # Don't forget escaping

  rule(:pclass => simple(:pclass)) { POSIXClass.new(pclass) }

  rule(:char_class => simple(:char_class)) { CharClass.new(char_class) }
  rule(:neg_class => simple(:neg_class))   { NegatedClass.new(neg_class) }

  rule(:predef => simple(:content)) { Predefined.new(content) }

  rule(:num1 => simple(:num1), :match_item => simple(:match_item)) { Repeat1.new(num1, match_item) }
  
  rule(:num1 => simple(:num1), :num2 => simple(:num2), :match_item => simple(:match_item)) { Repeat2.new(num1, num2, match_item) }

  rule(:qualifier => 'any',    :match_item => simple(:match_item)) { Any.new(match_item) }
  rule(:qualifier => 'many',   :match_item => simple(:match_item)) { Many.new(match_item) }
  rule(:qualifier => 'maybe',  :match_item => simple(:match_item)) { Maybe.new(match_item) }
  rule(:qualifier => 'nocase', :match_item => simple(:match_item)) { Nocase.new(match_item) }
  rule(:qualifier => 'within', :match_item => simple(:match_item)) { Within.new(match_item) }

## FIXME missing rules for lookarounds

=begin
--- ERROR: premature end of char-class: /{:definitions=>[], :match=>{:alternation=>{:sequence=>{:pospat=>Sequence(elements=[Repeat1(num1="3"@12, match_item=Predefined(pre="D"@14)), StringNode(string=" dollars"@17)]), :findpat=>Repeat1(num1="3"@33, match_item=Predefined(pre="D"@35))}}}}/
=end

  rule(:findpat => simple(:pla1), :pospat => simple(:pla2)) { PosAhead.new(pla1, pla2) }
  rule(:findpat => simple(:nla1), :negpat => simple(:nla2)) { NegAhead.new(nla1, nla2) }
  rule(:pospat => simple(:plb1), :findpat => simple(:plb2)) { PosBehind.new(plb1, plb2) }
  rule(:negpat => simple(:nlb1), :findpat => simple(:nlb2)) { NegBehind.new(nlb1, nlb2) }

  rule(:var => simple(:var), :rvalue => simple(:rvalue)) { Assignment.new(@var, @rvalue) }

  rule(:param => simple(:param)) { Parameter.new(param) }

  rule(:alternation => simple(:pattern))        { pattern }
  rule(:alternation => sequence(:alternatives)) { Alternation.new(alternatives) }

  rule(:sequence => simple(:element))    { element }
  rule(:sequence => sequence(:elements)) { Sequence.new(elements) }

  # A series of statements on different lines is also a sequence.
  rule(:lines => sequence(:lines)) { Sequence.new(lines) }
  
  rule(:var => simple(:name)) { Usage.new(name) }

  rule(:definitions => sequence(:definitions), :match => simple(:match)) { Program.new(definitions, match) }
  rule(:definitions => sequence(:definitions), :match => sequence(:match)) { Program.new(definitions, match) }

  # An expression of the form '@variable'
  rule(:lhs => {:cvar => simple(:backref)}) { Backref.new(backref) }

  # An expression of the form '@variable = expr'
  rule(:lhs => {:cvar => simple(:cname)}, :rhs => simple(:pattern)) { Captured.new(cname, pattern) }
end

