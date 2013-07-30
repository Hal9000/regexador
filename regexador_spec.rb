require 'pp'

require './regexador'

require 'parslet/rig/rspec'

class Object
  def front
    self.line_and_column.should == [1,1]
  end
end

describe Regexador::Parser do

before(:all) do
  @parser = Regexador::Parser.new 
  @pattern = @parser.pattern
end

describe "A special character" do
  it "can be matched as a pattern" do
    @parser.cSQUOTE.parse_with_debug("'").front
    @parser.cHASH.parse('#').front
    @parser.cNEWLINE.parse("\n").front
    @parser.cEQUAL.parse('=').front
  end
end

describe "A character literal" do
  it "can be matched as a pattern" do
    @pattern.parse('`a').front
    @pattern.parse('``').front
    @pattern.parse('`\\').front
  end
end

describe "A character string" do
  it "can be matched as a pattern" do
    @pattern.parse('"abcde"').front
    @pattern.parse('""').front
  end
end

describe "A character class" do
  it "can be matched as a pattern" do
    @pattern.parse("'abcdef'").front
    @pattern.parse("'x'").front
  end
end

describe "A negated character class" do
  it "can be matched as a pattern" do
    @pattern.parse("~'abcdef'").front
    @pattern.parse("~'x'").front
  end
end

describe "A character range" do
  it "can be matched as a pattern" do
    @pattern.parse("`a-`f").front
    @pattern.parse("`1-`6").front
  end
end

describe "A negated character range" do
  it "can be matched as a pattern" do
    @pattern.parse("`a~`f").front
    @pattern.parse("`1~`6").front
  end
end

describe "A pattern preceded by 'any/many/maybe'" do
  it "can be matched as a pattern" do
    @pattern.parse("any `a").front
    @pattern.parse("many 'xyz'").front
    @pattern.parse("maybe `1-`6").front

    @pattern.parse("any (`a)").front
    @pattern.parse("many ('xyz')").front
    @pattern.parse("maybe (`1-`6)").front
  end
end

describe "A set of alternative patterns" do
  it "can be matched as a pattern" do
    @pattern.parse("`a-`f | 'xyz'").front
    @pattern.parse('`1-`6| maybe "#"').front
    @pattern.parse('`a | `b|`c  | `d').front
  end
end

describe "A set of concatenated patterns" do
  it "can be matched as a pattern" do
    @pattern.parse("`a-`f 'xyz'").front
    @pattern.parse('`1-`6 maybe "#"').front
    @pattern.parse('`a  `b `c    `d').front
    @pattern.parse('"this" "that" maybe "other"').front
  end
end

describe "A pattern preceded by a repetition specifier" do
  it "can be matched as a pattern" do
    @pattern.parse("2 * `a").front
    @pattern.parse("3 * 'xyz'").front
    @pattern.parse("4 * `1-`6").front

    @pattern.parse("3,5 * (`a)").front
    @pattern.parse("4,7 * ('xyz')").front
    @pattern.parse("0,3 * (`1-`6)").front
  end
end

describe "An assignment" do
  it "can be parsed" do
    @parser.assignment.parse("a = 5").front
    @parser.assignment.parse("a= 5").front
    @parser.assignment.parse("a =5").front
    @parser.assignment.parse("a=5").front
    @parser.assignment.parse("myvar = 'xyz'").front
    @parser.assignment.parse('var2 = "hello"').front
    @parser.assignment.parse('this_var = `x-`z').front
    @parser.assignment.parse_with_debug('pat = maybe many `x-`z').front
  end
end

describe "A keyword used as a variable name" do
  it "will not parse" do
    @parser.assignment.should_not parse("endx = 'hello'")
#   @parser.assignment.parse("endx = 'hello'")
  end
end

describe "A definition section" do
  it "can be parsed" do
    defs1 = "a = 5\nstr = \"hello\"\n"
    @parser.definitions.parse_with_debug(defs1).front
    defs2 = <<-EOF
      a = 5
      pat = maybe many `a-`c
      str = "hello"
    EOF
    @parser.definitions.parse_with_debug(defs2).front
  end
end

describe "A one-line match clause" do
  it "can be parsed" do
    mc1 = <<-EOF
      match `a~`x end
    EOF
    @parser.match_clause.parse_with_debug(mc1).front
  end
end

describe "A multiline match clause" do
  it "can be parsed" do
    mc2 = <<-EOF
      match 
        `< "tag" WB 
        any ~`>
        # blah blah blah
        "</" "tag" `> 
      end
    EOF
    @parser.multiline_clause.parse_with_debug(mc2).front
  end
end

describe "An entire program" do
  it "can be parsed" do
    prog1 = <<-EOF
      dot = "."
      num = "25" D5 | `2 D4 D | maybe D1 1,2*D
      match WB num dot num dot num dot num WB end
    EOF
    @parser.program.parse_with_debug(prog1).front

    prog2 = <<-EOF
      # Warning: This one likely has errors!
  
      visa     = `4 12*D maybe 3*D
      mc       = `5 D5 14*D
      amex     = `3 '47' 13*D
      diners   = `3 (`0 D5 | '68' D) 11*D
      discover = `6 ("011" | `5 2*D) 12*D
      jcb      = ("2131"|"1800"|"35" 3*D) 11*D
  
      match visa | mc | amex | diners | discover | jcb end
    EOF
    @parser.program.parse_with_debug(prog2).front
  end
end

end

