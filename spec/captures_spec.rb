require './spec/testing'

describe Regexador do

  before(:all) do
    @parser = Regexador::Parser.new 
    @pattern = @parser.pattern
  end
  
  def self.program &block
    let(:code, &block)
    let(:program) { Program.new(code) }
    let(:regexp) { program.regexp }

    subject { program }
  end


  ### Test 1: US phone number

  describe "US phone number:" do
    prog = <<-'END'
      match
        @area_code = 3 * D
        `-
        @prefix = 3 * D
        `-
        @last4 = 4 * D
      end
    END

    program { prog }

    good = nil
    bad  = nil
    wanted = /(?<area_code>(\d){3})\-(?<prefix>(\d){3})\-(?<last4>(\d){4})/
    examples = [{"512-555-2001"=>{:area_code=>"512", :prefix=>"555", :last4=>"2001"}}]

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.should == wanted
    end

    examples.each do |example|
      example.each_pair do |str, results|
        mobj = rx.match(str)       # ordinary Ruby match object
        obj  = pattern.match(str)  # special object returned
        results.each_pair do |cvar, val| 
          it("grabs captures correctly") { mobj[cvar].should == val }
          it("exposes captures via method names") { obj.send(cvar).should == val }
        end
      end
    end
  end   # end of test


  ### Test 2: A simple backreference

  describe "A simple backreference:" do
    prog = <<-'END'
      tag = many %alpha
      match
        `<
        @tag = tag
        `>
        @cdata = any X
        "</" 
        @tag `>
      end
    END

    program { prog }

    good = nil
    bad  = nil
    wanted = /<(?<tag>([[:alpha:]])+)>(?<cdata>(.)*)<\/\k<tag>>/
    examples = [{"<body>abcd</body>"=>{:tag=>"body", :cdata=>"abcd"}}, {"<table>table</table>"=>{:tag=>"table", :cdata=>"table"}}]

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.should == wanted
    end

    examples.each do |example|
      example.each_pair do |str, results|
        mobj = rx.match(str)       # ordinary Ruby match object
        obj  = pattern.match(str)  # special object returned
        results.each_pair do |cvar, val| 
          it("grabs captures correctly") { mobj[cvar].should == val }
          it("exposes captures via method names") { obj.send(cvar).should == val }
        end
      end
    end
  end   # end of test


  ### Test 3: A simple backreference again

  describe "A simple backreference again:" do
    prog = <<-'END'
      tag = many %alpha
      match
        `<
        @tag = tag
        `>
        @cdata = any X
        "</" @tag `>     # Slightly different code
      end
    END

    program { prog }

    good = nil
    bad  = nil
    wanted = /<(?<tag>([[:alpha:]])+)>(?<cdata>(.)*)<\/\k<tag>>/
    examples = [{"<body>abcd</body>"=>{:tag=>"body", :cdata=>"abcd"}}, {"<table>table</table>"=>{:tag=>"table", :cdata=>"table"}}]

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.should == wanted
    end

    examples.each do |example|
      example.each_pair do |str, results|
        mobj = rx.match(str)       # ordinary Ruby match object
        obj  = pattern.match(str)  # special object returned
        results.each_pair do |cvar, val| 
          it("grabs captures correctly") { mobj[cvar].should == val }
          it("exposes captures via method names") { obj.send(cvar).should == val }
        end
      end
    end
  end   # end of test


  ### Test 4: A simple inline backreference with alternation

  describe "A simple inline backreference with alternation:" do
    prog = <<-'END'
      match
        BOS
        (@var = "x") | (@var = "y") 
        @var
        EOS
      end
    END

    program { prog }

    good = nil
    bad  = nil
    wanted = /^((?<var>x)|(?<var>y))\k<var>$/
    examples = [{"xx"=>{:var=>"x"}}, {"yy"=>{:var=>"y"}}]

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.should == wanted
    end

    # Is compiled result valid?

    examples.each do |example|
      example.each_pair do |str, results|
        mobj = rx.match(str)       # ordinary Ruby match object
        obj  = pattern.match(str)  # special object returned
        results.each_pair do |cvar, val| 
          it("grabs captures correctly") { mobj[cvar].should == val }
          it("exposes captures via method names") { obj.send(cvar).should == val }
        end
      end
    end
  end   # end of test


  ### Test 5: A simple inline capture

  describe "A simple inline capture:" do
    prog = "match `a @var = `b `c end"
    program { prog }

    good = nil
    bad  = nil
    wanted = /a(?<var>bc)/
    examples = [{"abc"=>{:var=>"bc"}}]

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.should == wanted
    end

    examples.each do |example|
      example.each_pair do |str, results|
        mobj = rx.match(str)       # ordinary Ruby match object
        obj  = pattern.match(str)  # special object returned
        results.each_pair do |cvar, val| 
          it("grabs captures correctly") { mobj[cvar].should == val }
          it("exposes captures via method names") { obj.send(cvar).should == val }
        end
      end
    end
  end   # end of test


  ### Test 6: A simple inline capture with parens

  describe "A simple inline capture with parens:" do
    prog = "match `a (@var = `b) `c end"
    program { prog }

    good = nil
    bad  = nil
    wanted = /a(?<var>b)c/
    examples = [{"abc"=>{:var=>"b"}}]

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.should == wanted
    end

    # Is compiled result valid?

    examples.each do |example|
      example.each_pair do |str, results|
        mobj = rx.match(str)       # ordinary Ruby match object
        obj  = pattern.match(str)  # special object returned
        results.each_pair do |cvar, val| 
          it("grabs captures correctly") { mobj[cvar].should == val }
          it("exposes captures via method names") { obj.send(cvar).should == val }
        end
      end
    end
  end   # end of test

end
