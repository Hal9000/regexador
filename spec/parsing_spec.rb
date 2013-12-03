# Encoding: UTF-8
require './spec/testing'

class Object
  def succeeds
    self.should_not == nil 
  end
end

describe Regexador do
  before(:all) do
    @parser = Regexador::Parser.new 
    @pattern = @parser.pattern
  end
  
  describe "A special character" do
    it "can be matched correctly" do
      @parser.cSQUOTE.parse_with_debug("'").succeeds
      @parser.cHASH.parse('#').succeeds
      @parser.cNEWLINE.parse("\n").succeeds
      @parser.cEQUAL.parse('=').succeeds
    end
  end

  describe "An international character" do
    it "can follow a backtick" do  # 
      @parser.char.parse_with_debug("`æ").succeeds
      @parser.char.parse("`ß").succeeds
      @parser.char.parse("`ç").succeeds
      @parser.char.parse("`ö").succeeds
      @parser.char.parse("`ñ").succeeds
    end
  end

  describe "A Unicode codepoint expression" do
    it "can be matched" do
      @parser.codepoint.parse_with_debug("&1234").succeeds
      @parser.codepoint.parse('&beef').succeeds
    end
  end

  describe "A predefined token" do
    %w(BOS EOS START END).each do |token|
      describe token do
        it 'matches using pattern' do
          @parser.pattern.parse_with_debug(token).succeeds
        end
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

  describe "A capture variable" do
    it "can be parsed" do
      str1 = "@myvar"
      @parser.capture_var.parse(str1).succeeds
    end
  end

  describe "A captured pattern" do
    let(:prog) { "@myvar = maybe 'abc'" }

    it "can be parsed (#capture)" do
      @parser.capture.parse(prog).succeeds
    end
    it "can be parsed (#program)" do
      @parser.parse("match #{prog} end").succeeds
    end
  end
  describe "A back reference" do
    let(:prog) { '@myvar' }

    it 'can be parsed (#capture)' do
      @parser.capture.parse(prog).succeeds
    end
    it 'can be parsed' do
      @parser.parse("match #{prog} end").succeeds
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
end

