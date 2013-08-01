require 'pp'

require './regexador'

require 'parslet/rig/rspec'

class Object
  def succeeds
    self.should_not == nil 
  end
end

describe Regexador do

 @oneliners = 
   [
     [ "simple range",    "match `a-`f end", 
                          /[a-f]/ ],
     [ "negated range",   "match `c~`p end", 
                          /[^c-p]/ ],
     [ "negated char",    "match ~`d end", 
                          /[^d]/ ],
     [ "POSIX class",     "match %alnum end", 
                          /[[:alnum:]]/ ],
     [ "bracket class",   "match 'prstu' end", 
                          /[prstu]/ ],
     [ "neg. bracket",    "match ~'lmno' end", 
                          /[^lmno]/ ],
     [ "BOS",             "match BOS end",    # silly
                          /^/ ],
     [ "EOS",             "match EOS end",    # silly
                          /$/ ],
     [ "WB",              "match WB end",     # silly
                          /\b/ ],
     [ "string",          'match "xyz" end',
                          /xyz/ ],
     [ "repeat 1",        'match 5 * "xyz" end',
                          /(xyz){5}/ ],
     [ "repeat 2",        'match 3,4 * %alpha end',
                          /([[:alpha:]]){3,4}/ ],
     [ "any",             'match any "abc" end',
                          /(abc)*/ ],
     [ "many",            'match any "def" end',
                          /(def)*/ ],
     [ "maybe",           'match any "ghi" end',
                          /(ghi)?/ ],
   ]

 @simple_patterns = 
     [
       '`a',        '``',           '`\\',           '"abcde"',  
       '""',        "'abcdef'",     "'x'",           "~'abcdef'",
       "~'x'",      "`a-`f",        "`1-`6",         "`a~`f",
       "`1~`6",     "any `a",       "many 'xyz'",    "maybe `1-`6",  
       "any (`a)",  "many ('xyz')", "maybe (`1-`6)", "`a-`f | 'xyz'",  
       '`1-`6| maybe "#"',          '`a | `b|`c|`d',  
       "`a-`f 'xyz'",               '`1-`6 maybe "#"',  
       '`a  `b `c    `d',           '"this" "that" maybe "other"',  
       "2 * `a",    "3 * 'xyz'",    "4 * `1-`6",     "3,5 * (`a)",  
       "4,7 * ('xyz')",             "0,3 * (`1-`6)"  
     ]

before(:all) do
  @parser = Regexador::Parser.new 
  @pattern = @parser.pattern
end

describe "A special character" do
  it "can be matched as a pattern" do
    @parser.cSQUOTE.parse_with_debug("'").succeeds
    @parser.cHASH.parse('#').succeeds
    @parser.cNEWLINE.parse("\n").succeeds
    @parser.cEQUAL.parse('=').succeeds
  end
end

@simple_patterns.each do |pat|
  describe "A one-line program (#{pat.inspect})" do
    it "can be parsed" do
      @pattern.parse(pat).succeeds
    end
  end 
end


describe "An assignment" do
  it "can be parsed" do
    @parser.assignment.parse("a = 5").succeeds
    @parser.assignment.parse("a= 5").succeeds
    @parser.assignment.parse("a =5").succeeds
    @parser.assignment.parse("a=5").succeeds
    @parser.assignment.parse("myvar = 'xyz'").succeeds
    @parser.assignment.parse('var2 = "hello"').succeeds
    @parser.assignment.parse('this_var = `x-`z').succeeds
    @parser.assignment.parse_with_debug('pat = maybe many `x-`z').succeeds
  end
end

describe "A keyword used as a variable name" do
  it "will not parse" do
    @parser.assignment.should_not parse("end = 'hello'")
#   @parser.assignment.parse("endx = 'hello'")
  end
end

describe "A definition section" do
  it "can be parsed" do
    defs1 = "a = 5\nstr = \"hello\"\n"
    @parser.definitions.parse_with_debug(defs1).succeeds
    defs2 = <<-EOF
      a = 5
      # comment...
      pat = maybe many `a-`c
      # empty line follows:

      str = "hello"
      # another comment...
    EOF
    @parser.definitions.parse_with_debug(defs2).succeeds
  end
end

describe "A one-line match clause" do
  it "can be parsed" do
    mc1 = <<-EOF
      match `a~`x end
    EOF
    @parser.match_clause.parse_with_debug(mc1).succeeds
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
    @parser.multiline_clause.parse_with_debug(mc2).succeeds
  end
end

describe "An entire one-line program" do
  it "can be parsed" do
    prog = "match `a-`f end"
    @parser.parse_with_debug(prog).succeeds
  end
end


describe "An entire program" do
  it "can be parsed" do
    prog1 = <<-EOF
      dot = "."
      num = "25" D5 | `2 D4 D | maybe D1 1,2*D
      match WB num dot num dot num dot num WB end
    EOF
    @parser.program.parse_with_debug(prog1).succeeds

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
    @parser.program.parse_with_debug(prog2).succeeds
  end
end

#### "Real" tests

@oneliners.each do |desc, prog, wanted|
  describe "A one-line program (#{desc})" do
    it "can be parsed" do
      @parser.parse(prog).succeeds
    end
    it "can be converted to a regex" do
      Regexador.new(prog).to_regex.should == wanted
    end
  end 
end


end

