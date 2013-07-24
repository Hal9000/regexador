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
    @pattern.parse("~`a-`f").front
    @pattern.parse("~`1-`6").front
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

end
