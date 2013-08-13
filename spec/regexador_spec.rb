require_relative '../lib/regexador'
require 'pp'

require 'parslet/convenience'
require 'parslet/rig/rspec'

class Object
  def succeeds
    self.should_not == nil 
  end
end

class Program
  attr_accessor :description, :program, :regex, :good, :bad
end

class Capture
  attr_accessor :description, :program, :regex, :examples
  # examples is a hash of the form:
  #   { str1 => {var1 => exp1, var2 => exp2, ...}, 
  #     str2 => {var1 => exp1, var2 => exp2, ...}, 
  #     ...}
end


####


describe Regexador do

  @oneliners = YAML.load(File.read("spec/oneliners.yaml"))
  @programs  = YAML.load(File.read("spec/programs.yaml"))
  @captures  = YAML.load(File.read("spec/captures.yaml"))

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
  
  #### "Real" tests (data-driven)
  
  @oneliners.each do |x|
    desc, pat, wanted, good, bad = 
      x.description, x.program, x.regex, x.good, x.bad
    describe "A one-pattern program (#{desc})" do
      prog = "match #{pat} end"
      it("can be parsed") { @parser.parse(prog).succeeds }
      rx = nil
      it "can be converted to a regex" do
        rx = Regexador.new(prog).to_regex
        rx.class.should == Regexp
        if wanted    # Allow missing regex in test data
          rx.should == wanted
        end
      end
      good.each {|str| it("matches #{str.inspect}") { str =~ rx } }
      bad.each  {|str| it("fails to match #{str.inspect}") { str !~ rx } }
    end 
  end
  
  $debug = true
  
  @programs.each do |x|
    desc, prog, wanted, good, bad = 
      x.description, x.program, x.regex, x.good, x.bad
    describe "A complete program (#{desc})" do
      it("can be parsed") { @parser.parse(prog).succeeds }
      rx = nil
      it "can be converted to a regex" do
        rx = Regexador.new(prog).to_regex
        rx.should == wanted
      end
      good.each {|str| it("matches #{str.inspect}") { str =~ rx } }
      bad.each  {|str| it("fails to match #{str.inspect}") { str !~ rx } }
    end 
  end

#   @captures.each do |x|
#     desc, prog, wanted, examples = 
#       x.description, x.program, x.regex, x.examples
#     describe "A program with captures (#{desc})" do
#       it("can be parsed") { @parser.parse(prog).succeeds }
#       rx = nil
#       it "can be converted to a regex" do
#         rx = Regexador.new(prog).to_regex
#         rx.class.should == Regexp
#         if wanted
#           rx.should == wanted
#         end
#       end
#       examples.each do |str, results|
#         obj = rx.match(str)
#         results.each do |capture, value|
#           obj.send(capture).should == value
#         end
#       end 
#     end 
#   end
  
end

