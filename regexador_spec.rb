require 'pp'

require './regexador'

class Object
  def front
    self.line_and_column.should == [1,1]
  end
end

describe RegexadorParser do

before(:all) do
  @parser = RegexadorParser.new 
  @pattern = @parser.pattern
end

describe "A special character" do
  it "can be matched as a pattern" do
    @parser.cSQUOTE.parse("'").front
    @parser.cHASH.parse('#').front
    @parser.cNEWLINE.parse("\n").front
    @parser.cEQUAL.parse('=').front
  end
end

describe "A character literal" do
  it "can be matched as a pattern" do
    @pattern.parse('`a').front
    @pattern.parse('``').front
    @pattern.parse('`\\').front # Ruby string is escaped
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
    @parser.assignment.parse_with_debug('var3 = maybe many `x-`z').front
  end
end

describe "A definition section" do
  it "can be parsed" do
    defs1 = <<-EOF
      a = 5
      str = "hello"
      pat = maybe many `a-`c
    EOF
    @parser.definitions.parse_with_debug(defs1).front
  end
end

describe "A match clause" do
  it "can be parsed" do
    mc1 = <<-EOF
      match `a~`x end
    EOF
puts mc1
    @parser.match_clause.parse_with_debug(mc1).front
    mc2 = <<-EOF
      match 
        `< "tag" WB 
        any ~`>
        # blah blah blah
        "</" "tag" `> 
      end
    EOF
puts mc2
    @parser.match_clause.parse_with_debug(mc2).front
  end
end

end
