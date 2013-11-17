  require_relative '../lib/regexador'
  require 'pp'

  require 'parslet/convenience'
  require 'parslet/rig/rspec'

  describe Regexador do

  before(:all) do
    @parser = Regexador::Parser.new 
    @pattern = @parser.pattern
  end
  
  class Program
    attr_accessor :description, :program, :regex, :good, :bad, :examples

    def initialize(full_program)
      @code = @full_program = full_program
      @parser = Regexador::Parser.new 
    end

    def parseable?
      result = @parser.parse(@full_program) rescue nil  # != nil
      !! result
    end

    def parse_pattern  # FIXME no longer used?
      tree = @parser.pattern.parse(@code)
      tree = tree[:alternation]         if tree.size == 1 && tree.keys.first == :alternation
      tree = tree[:sequence].first         if tree.size == 1 && tree.keys.first == :sequence
      tree
    end

    def parse
      tree = @parser.parse(@full_program)
    end

    def debug_bad_program_parse
      @parser.parse(@full_program)
      atree = nil
    rescue Parslet::ParseFailed => error
      atree = error.cause.ascii_tree.split("
")
      lchar = /at line (d+) char (d+).$/
      fname = rand(10**5).to_s + ".tree"
      File.open(fname, "w") {|f| f.puts @full_program + "
" + atree.join("
") }
      puts "See file: " + fname
      return
      # FIXME bad logic below
      begin
        atree.map! do |line|
          line.gsub!(/`- ||- ||  /, "   ")
          _, ln, cn = line.match(lchar).to_a
          line.sub!(lchar, "")
          line.sub!(/   /, "  ")
          line = '%-5s' % (ln+':'+cn) + line
        end
      rescue
      end
      puts atree
    end

    def regexp
      Regexador.new(@full_program).to_regex
    end
  end


  def self.program &block
    let(:code, &block)
    let(:program) { Program.new(code) }
    let(:regexp) { program.regexp }

    subject { program }
  end

    ### Test 1: Single char

    describe "A correct program (Single char)" do
      prog = <<-'END'
        match `x end
      END

      good = ["abcx", "xyzb", "x"]
      bad  = ["yz", "", "ABC"]
      wanted = /x/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 2: Unicode codepoint

    describe "A correct program (Unicode codepoint)" do
      prog = <<-'END'
        match &20ac end
      END

      good = ["€", "xyz€", "x€yz"]
      bad  = ["yz", "", "ABC"]
      wanted = /€/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 3: Manual international characters

    describe "A correct program (Manual international characters)" do
      prog = <<-'END'
        match "ö" end
      END

      good = ["öffnen", "xyzö", "xöyz"]
      bad  = ["offnen", "yz", "", "ABC"]
      wanted = /ö/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 4: Simple range

    describe "A correct program (Simple range)" do
      prog = <<-'END'
        match `a-`f end
      END

      good = ["alpha", "xyzb", "c"]
      bad  = ["xyz", "", "ABC"]
      wanted = /[a-f]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 5: Negated range

    describe "A correct program (Negated range)" do
      prog = <<-'END'
        match `c~`p end
      END

      good = ["ab", "rst"]
      bad  = ["def", "mno", ""]
      wanted = /[^c-p]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 6: Negated char

    describe "A correct program (Negated char)" do
      prog = <<-'END'
        match ~`d end
      END

      good = ["xyz", "123"]
      bad  = ["d", "dd"]
      wanted = /[^d]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 7: POSIX class

    describe "A correct program (POSIX class)" do
      prog = <<-'END'
        match %alnum end
      END

      good = ["abc365", "237", "xyz"]
      bad  = ["---", ":,.-"]
      wanted = /[[:alnum:]]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 8: Simple char class

    describe "A correct program (Simple char class)" do
      prog = <<-'END'
        match 'prstu' end
      END

      good = ["du", "ppp", "sr"]
      bad  = ["abc", "xyz"]
      wanted = /[prstu]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 9: Negated char class

    describe "A correct program (Negated char class)" do
      prog = <<-'END'
        match ~'ilmnop' end
      END

      good = ["abacus", "peccata", "hydrogen"]
      bad  = ["oil", "pill"]
      wanted = /[^ilmnop]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 10: Predef Beginning of string

    describe "A correct program (Predef Beginning of string)" do
      prog = <<-'END'
        match BOS end
      END

      good = [""]
      bad  = []
      wanted = /^/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 11: Predef End of string

    describe "A correct program (Predef End of string)" do
      prog = <<-'END'
        match EOS end
      END

      good = [""]
      bad  = []
      wanted = /$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 12: Predef Word boundary

    describe "A correct program (Predef Word boundary)" do
      prog = <<-'END'
        match WB end
      END

      good = ["xyz"]
      bad  = ["", "---"]
      wanted = /\b/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 13: Simple string

    describe "A correct program (Simple string)" do
      prog = <<-'END'
        match "xyz" end
      END

      good = ["xyz", "abcxyzdef"]
      bad  = ["abc", "xydefz"]
      wanted = /xyz/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 14: Single-bounded repetition

    describe "A correct program (Single-bounded repetition)" do
      prog = <<-'END'
        match 5 * "xyz" end
      END

      good = ["xyzxyzxyzxyzxyz"]
      bad  = ["xyzxyzxyzxyz"]
      wanted = /(xyz){5}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 15: Double-bounded repetition

    describe "A correct program (Double-bounded repetition)" do
      prog = <<-'END'
        match 3,4 * %alpha end
      END

      good = ["abc", "abcd"]
      bad  = ["ab", "x"]
      wanted = /([[:alpha:]]){3,4}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 16: any-qualifier

    describe "A correct program (any-qualifier)" do
      prog = <<-'END'
        match any "abc" end
      END

      good = ["", "abc", "abcabc", "xyz"]
      bad  = []
      wanted = /(abc)*/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 17: many-qualifier

    describe "A correct program (many-qualifier)" do
      prog = <<-'END'
        match many "def" end
      END

      good = ["def", "defdef", "defdefdef"]
      bad  = ["", "de", "xyz"]
      wanted = /(def)+/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 18: nocase-qualifier

    describe "A correct program (nocase-qualifier)" do
      prog = <<-'END'
        match nocase "ghi" end
      END

      good = ["ghi", "GHI", "abGhicd"]
      bad  = ["", "gh", "abc"]
      wanted = /((?i)ghi)/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 19: maybe-qualifier

    describe "A correct program (maybe-qualifier)" do
      prog = <<-'END'
        match maybe "ghi" end
      END

      good = ["", "ghi", "abghicd", "gh"]
      bad  = []
      wanted = /(ghi)?/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 20: Simple concatenation of two strings

    describe "A correct program (Simple concatenation of two strings)" do
      prog = <<-'END'
        match "abc" "def" end
      END

      good = ["abcdefghi", "xyzabcdef"]
      bad  = ["", "abcxyzdef"]
      wanted = /abcdef/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 21: Concat of string and char class

    describe "A correct program (Concat of string and char class)" do
      prog = <<-'END'
        match "abc"'def' end
      END

      good = ["abcd", "abce"]
      bad  = ["", "abcx"]
      wanted = /abc[def]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 22: Simple alternation

    describe "A correct program (Simple alternation)" do
      prog = <<-'END'
        match "abc" | "def" end
      END

      good = ["abc", "xyzabc123", "xdefy"]
      bad  = ["", "abde", "ab c d ef"]
      wanted = /(abc|def)/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 23: Alternation of concatenations

    describe "A correct program (Alternation of concatenations)" do
      prog = <<-'END'
        match "ab" "c" | "d" "ef" end
      END

      good = ["abc", "xyzabc123", "xdefy"]
      bad  = ["", "abde", "ab c d ef"]
      wanted = /(abc|def)/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 24: Precedence of concatenation over alternation

    describe "A correct program (Precedence of concatenation over alternation)" do
      prog = <<-'END'
        match "a" "b" | "c" end
      END

      good = ["ab", "c"]
      bad  = ["b", "a", "d"]
      wanted = /(ab|c)/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 25: Precedence of parens over concatenation

    describe "A correct program (Precedence of parens over concatenation)" do
      prog = <<-'END'
        match "a" ("b" | "c") end
      END

      good = ["ab", "ac"]
      bad  = ["a", "b", "c"]
      wanted = /a(b|c)/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 26: Anchors and alternation

    describe "A correct program (Anchors and alternation)" do
      prog = <<-'END'
        match BOS "x" | "y" EOS end
      END

      good = ["xabc", "abcy"]
      bad  = ["abc", "abcx", "yabc", "axb", "ayb", "axyb"]
      wanted = /(^x|y$)/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 27: Anchors, alternation, parens

    describe "A correct program (Anchors, alternation, parens)" do
      prog = <<-'END'
        match BOS ("x" | "y") EOS end
      END

      good = ["x", "y"]
      bad  = ["abc", "abcx", "yabc", "xabc", "abcy"]
      wanted = /^(x|y)$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 28: Parens, concatenation, alternation

    describe "A correct program (Parens, concatenation, alternation)" do
      prog = <<-'END'
        match BOS ((maybe `0) `1-`9 | `1 D2) EOS end
      END

      good = ["01", "09", "12"]
      bad  = ["0", "00", "13"]
      wanted = /^((0)?[1-9]|1[0-2])$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 29: Single backtick char

    describe "A correct program (Single backtick char)" do
      prog = <<-'END'
        match `` end
      END

      good = ["`", "this is a tick: `", "tock ` tock"]
      bad  = ["", "abc"]
      wanted = /`/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 30: Single backslash char

    describe "A correct program (Single backslash char)" do
      prog = <<-'END'
        match `\ end
      END

      good = ["\\", "trying \\n", "and \\b also"]
      bad  = ["\n", "\b", "neither \r nor \t"]
      wanted = /\\/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 31: Empty string

    describe "A correct program (Empty string)" do
      prog = <<-'END'
        match "" end
      END

      good = ["", "abc"]
      bad  = []
      wanted = //

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 32: Simple char class

    describe "A correct program (Simple char class)" do
      prog = <<-'END'
        match 'abcdef' end
      END

      good = ["there's a cat here", "item c"]
      bad  = ["", "proton"]
      wanted = /[abcdef]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 33: Simple one-char class

    describe "A correct program (Simple one-char class)" do
      prog = <<-'END'
        match 'x' end
      END

      good = ["x", "uvwxyz"]
      bad  = ["", "abc"]
      wanted = /[x]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 34: Alternation of range and class

    describe "A correct program (Alternation of range and class)" do
      prog = <<-'END'
        match `a-`f | 'xyz' end
      END

      good = ["a", "x", "z", "c"]
      bad  = ["", "jkl", "gw"]
      wanted = /([a-f]|[xyz])/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 35: Alternation of range and maybe-clause

    describe "A correct program (Alternation of range and maybe-clause)" do
      prog = <<-'END'
        match `1-`6| maybe "#" end
      END

      good = ["", "1#", "1", " 2# abc"]
      bad  = []
      wanted = /([1-6]|(\#)?)/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 36: Four-way alternation

    describe "A correct program (Four-way alternation)" do
      prog = <<-'END'
        match `a | `b|`c|`d end
      END

      good = ["xyza", "xybz", "xcyz", "dxyz"]
      bad  = ["", "every", "ghijk"]
      wanted = /(a|b|c|d)/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 37: Concatenation of range and class

    describe "A correct program (Concatenation of range and class)" do
      prog = <<-'END'
        match `a-`f 'xyz' end
      END

      good = ["ax", "fz", "cy"]
      bad  = ["zf", "xa", "gz", "hp", "mx"]
      wanted = /[a-f][xyz]/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 38: Concat of strings and maybe-clause

    describe "A correct program (Concat of strings and maybe-clause)" do
      prog = <<-'END'
        match "this" "that" maybe "other" end
      END

      good = ["thisthat", "thisthatother", "abc thisthat xyz", "abc thisthatother xyz"]
      bad  = ["", "abc", "this that", "this that other"]
      wanted = /thisthat(other)?/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 39: Simple repetition of class

    describe "A correct program (Simple repetition of class)" do
      prog = <<-'END'
        match 3 * 'xyz' end
      END

      good = ["xyz", "xxx", "yzy", "xyzzy123"]
      bad  = ["", "abc", "xy", "axy", "xyb", "axyb"]
      wanted = /([xyz]){3}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 40: Simple repetition of range

    describe "A correct program (Simple repetition of range)" do
      prog = <<-'END'
        match 4 * `1-`6 end
      END

      good = ["1111", "1234", "abc 6543 def"]
      bad  = ["", "abc", "123", "123 4"]
      wanted = /([1-6]){4}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 41: Complex repetition of char

    describe "A correct program (Complex repetition of char)" do
      prog = <<-'END'
        match 3,5 * (`a) end
      END

      good = ["aaa", "aaaa", "aaaaa", "xaaay", "aaaaaaa"]
      bad  = ["", "abc", "aa"]
      wanted = /(a){3,5}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 42: Complex repetition of parenthesized class

    describe "A correct program (Complex repetition of parenthesized class)" do
      prog = <<-'END'
        match 4,7 * ('xyz') end
      END

      good = ["xxxx", "yyyy", "xyzy", "xyzzy", "zyzzyva", "xyzxyz", "xyzxyzx", "xyzxyzxyzxyz"]
      bad  = ["", "abc", "x", "xx", "xxx", "xyz xy"]
      wanted = /([xyz]){4,7}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 43: Complex repetition of parenthesized range

    describe "A correct program (Complex repetition of parenthesized range)" do
      prog = <<-'END'
        match 0,3 * (`1-`6) end
      END

      good = ["", "1", "11", "111", "56", "654", "1111", "x123y", "x123456y"]
      bad  = []
      wanted = /([1-6]){0,3}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 44: Single char (anchored)

    describe "A correct program (Single char (anchored))" do
      prog = <<-'END'
        match BOS `x EOS end
      END

      good = ["x"]
      bad  = ["yz", "", "ABC"]
      wanted = /^x$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 45: Simple range (anchored)

    describe "A correct program (Simple range (anchored))" do
      prog = <<-'END'
        match BOS `a-`f EOS end
      END

      good = ["a", "b", "c", "d", "e", "f"]
      bad  = ["xyz", "", "ABC"]
      wanted = /^[a-f]$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 46: Negated range (anchored)

    describe "A correct program (Negated range (anchored))" do
      prog = <<-'END'
        match BOS `c~`p EOS end
      END

      good = ["a", "r"]
      bad  = ["def", "mno", ""]
      wanted = /^[^c-p]$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 47: Negated char (anchored)

    describe "A correct program (Negated char (anchored))" do
      prog = <<-'END'
        match BOS ~`d EOS end
      END

      good = ["x", "1"]
      bad  = ["d", "dd", "abc"]
      wanted = /^[^d]$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 48: POSIX class (anchored)

    describe "A correct program (POSIX class (anchored))" do
      prog = <<-'END'
        match BOS %alnum EOS end
      END

      good = ["c", "2"]
      bad  = ["", "abc", "123", "-", ":", ",", "."]
      wanted = /^[[:alnum:]]$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 49: Simple char class (anchored)

    describe "A correct program (Simple char class (anchored))" do
      prog = <<-'END'
        match BOS 'prstu' EOS end
      END

      good = ["u", "p", "s"]
      bad  = ["", "abc", "x"]
      wanted = /^[prstu]$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 50: Negated char class (anchored)

    describe "A correct program (Negated char class (anchored))" do
      prog = <<-'END'
        match BOS ~'ilmnop' EOS end
      END

      good = ["a", "e", "h"]
      bad  = ["o", "i", "l"]
      wanted = /^[^ilmnop]$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 51: Simple string (anchored)

    describe "A correct program (Simple string (anchored))" do
      prog = <<-'END'
        match BOS "xyz" EOS end
      END

      good = ["xyz"]
      bad  = ["", "abc", "abcxyzdef", "xydefz"]
      wanted = /^xyz$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 52: Single-bounded repetition (anchored)

    describe "A correct program (Single-bounded repetition (anchored))" do
      prog = <<-'END'
        match BOS 5 * "xyz" EOS end
      END

      good = ["xyzxyzxyzxyzxyz"]
      bad  = ["xyzxyzxyzxyz", "abcxyzxyzxyzxyz", "xyzxyzxyzxyzabc"]
      wanted = /^(xyz){5}$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 53: Double-bounded repetition (anchored)

    describe "A correct program (Double-bounded repetition (anchored))" do
      prog = <<-'END'
        match BOS 3,4 * %alpha EOS end
      END

      good = ["abc", "abcd"]
      bad  = ["", "ab", "x", "abcde"]
      wanted = /^([[:alpha:]]){3,4}$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 54: any-qualifier (anchored)

    describe "A correct program (any-qualifier (anchored))" do
      prog = <<-'END'
        match BOS any "abc" EOS end
      END

      good = ["", "abc", "abcabc", "abcabcabc"]
      bad  = ["ab", "abcab", "xyz"]
      wanted = /^(abc)*$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 55: many-qualifier (anchored)

    describe "A correct program (many-qualifier (anchored))" do
      prog = <<-'END'
        match BOS many "def" EOS end
      END

      good = ["def", "defdef", "defdefdef"]
      bad  = ["", "d", "de", "defd", "xyz"]
      wanted = /^(def)+$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 56: maybe-qualifier (anchored)

    describe "A correct program (maybe-qualifier (anchored))" do
      prog = <<-'END'
        match BOS maybe "ghi" EOS end
      END

      good = ["", "ghi"]
      bad  = ["abghicd", "gh"]
      wanted = /^(ghi)?$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 57: Simple concatenation of two strings (anchored)

    describe "A correct program (Simple concatenation of two strings (anchored))" do
      prog = <<-'END'
        match BOS "abc" "def" EOS end
      END

      good = ["abcdef"]
      bad  = ["", "abcd", "xyzabcdef", "abcxyzdef", "abcdefxyz"]
      wanted = /^abcdef$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 58: Concat of string and char class (anchored)

    describe "A correct program (Concat of string and char class (anchored))" do
      prog = <<-'END'
        match BOS "abc" 'def' EOS end
      END

      good = ["abcd", "abce", "abcf"]
      bad  = ["", "ab", "abc", "abcx"]
      wanted = /^abc[def]$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 59: Simple alternation (anchored)

    describe "A correct program (Simple alternation (anchored))" do
      prog = <<-'END'
        match BOS ("abc" | "def") EOS end
      END

      good = ["abc", "def"]
      bad  = ["", "abde", "ab c d ef", "xdefy"]
      wanted = /^(abc|def)$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 60: Alternation of concatenations (anchored)

    describe "A correct program (Alternation of concatenations (anchored))" do
      prog = <<-'END'
        match BOS ("ab" "c" | "d" "ef") EOS end
      END

      good = ["abc", "def"]
      bad  = ["", "abde", "ab c d ef", "xdefy"]
      wanted = /^(abc|def)$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 61: Precedence of concatenation over alternation (anchored)

    describe "A correct program (Precedence of concatenation over alternation (anchored))" do
      prog = <<-'END'
        match BOS ("a" "b" | "c") EOS end
      END

      good = ["ab", "c"]
      bad  = ["", "b", "a", "d", "abc", "abcde"]
      wanted = /^(ab|c)$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 62: Precedence of parens over concatenation (anchored)

    describe "A correct program (Precedence of parens over concatenation (anchored))" do
      prog = <<-'END'
        match BOS "a" ("b" | "c") EOS end
      END

      good = ["ab", "ac"]
      bad  = ["a", "b", "c", "abc", "abx", "bac"]
      wanted = /^a(b|c)$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 63: Anchors and alternation (anchored)

    describe "A correct program (Anchors and alternation (anchored))" do
      prog = <<-'END'
        match BOS "x" | "y" EOS end
      END

      good = ["xabc", "abcy"]
      bad  = ["abc", "abcx", "yabc", "axb", "ayb", "axyb"]
      wanted = /(^x|y$)/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 64: Parens, concatenation, alternation (anchored)

    describe "A correct program (Parens, concatenation, alternation (anchored))" do
      prog = <<-'END'
        match BOS ((maybe `0) `1-`9 | `1 D2) EOS end
      END

      good = ["01", "09", "12"]
      bad  = ["0", "00", "13"]
      wanted = /^((0)?[1-9]|1[0-2])$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 65: Single backtick char (anchored)

    describe "A correct program (Single backtick char (anchored))" do
      prog = <<-'END'
        match BOS `` EOS end
      END

      good = ["`"]
      bad  = ["", "abc", "this is a tick: `", "tock ` tock"]
      wanted = /^`$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 66: Single backslash char (anchored)

    describe "A correct program (Single backslash char (anchored))" do
      prog = <<-'END'
        match BOS `\ EOS end
      END

      good = ["\\"]
      bad  = ["\n", "\b", "neither \r nor \t", "trying \\n", "and \\b also"]
      wanted = /^\\$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 67: Empty string (anchored)

    describe "A correct program (Empty string (anchored))" do
      prog = <<-'END'
        match BOS "" EOS end
      END

      good = [""]
      bad  = ["abc"]
      wanted = /^$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 68: Simple one-char class (anchored)

    describe "A correct program (Simple one-char class (anchored))" do
      prog = <<-'END'
        match BOS 'x' EOS end
      END

      good = ["x"]
      bad  = ["", "abc", "uvwxyz"]
      wanted = /^[x]$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 69: Alternation of range and class (anchored)

    describe "A correct program (Alternation of range and class (anchored))" do
      prog = <<-'END'
        match BOS (`a-`f | 'xyz') EOS end
      END

      good = ["a", "x", "z", "c"]
      bad  = ["", "ab", "abc", "xy", "jkl", "gw"]
      wanted = /^([a-f]|[xyz])$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 70: Alternation of range and maybe-clause (anchored)

    describe "A correct program (Alternation of range and maybe-clause (anchored))" do
      prog = <<-'END'
        match BOS (`1-`6| maybe "#") EOS end
      END

      good = ["", "1", "#", "6"]
      bad  = ["55", "###"]
      wanted = /^([1-6]|(\#)?)$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 71: Four-way alternation (anchored)

    describe "A correct program (Four-way alternation (anchored))" do
      prog = <<-'END'
        match BOS (`a | `b|`c|`d) EOS end
      END

      good = ["a", "b", "c", "d"]
      bad  = ["", "ab", "every", "ghijk"]
      wanted = /^(a|b|c|d)$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 72: Concatenation of range and class (anchored)

    describe "A correct program (Concatenation of range and class (anchored))" do
      prog = <<-'END'
        match BOS `a-`f 'xyz' EOS end
      END

      good = ["ax", "fz", "cy"]
      bad  = ["axe", "fz123", "zf", "xa", "gz", "hp", "mx"]
      wanted = /^[a-f][xyz]$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 73: Concat of strings and maybe-clause (anchored)

    describe "A correct program (Concat of strings and maybe-clause (anchored))" do
      prog = <<-'END'
        match BOS "this" "that" maybe "other" EOS end
      END

      good = ["thisthat", "thisthatother"]
      bad  = ["", "abc", "this that", "this that other", "abc thisthat xyz", "abc thisthatother xyz"]
      wanted = /^thisthat(other)?$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 74: Simple repetition of class (anchored)

    describe "A correct program (Simple repetition of class (anchored))" do
      prog = <<-'END'
        match BOS 3 * 'xyz' EOS end
      END

      good = ["xyz", "xxx", "yzy"]
      bad  = ["", "abc", "xy", "axy", "xyb", "axyb", "xyzzy123"]
      wanted = /^([xyz]){3}$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 75: Simple repetition of range (anchored)

    describe "A correct program (Simple repetition of range (anchored))" do
      prog = <<-'END'
        match BOS 4 * `1-`6 EOS end
      END

      good = ["1111", "1234"]
      bad  = ["", "abc", "123", "123 4", "abc 6543 def"]
      wanted = /^([1-6]){4}$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 76: Complex repetition of char (anchored)

    describe "A correct program (Complex repetition of char (anchored))" do
      prog = <<-'END'
        match BOS 3,5 * (`a) EOS end
      END

      good = ["aaa", "aaaa", "aaaaa"]
      bad  = ["", "abc", "aa", "xaaay", "aaaaaaa"]
      wanted = /^(a){3,5}$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 77: Complex repetition of parenthesized class (anchored)

    describe "A correct program (Complex repetition of parenthesized class (anchored))" do
      prog = <<-'END'
        match BOS 4,7 * ('xyz') EOS end
      END

      good = ["xxxx", "yyyy", "xyzy", "xyzzy", "xyzxyz", "xyzxyzx"]
      bad  = ["", "abc", "x", "xx", "xxx", "xyz xy", "xyzxyzxyzxyz", "zyzzyva"]
      wanted = /^([xyz]){4,7}$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 78: Complex repetition of parenthesized range (anchored)

    describe "A correct program (Complex repetition of parenthesized range (anchored))" do
      prog = <<-'END'
        match BOS 0,3 * (`1-`6) EOS end
      END

      good = ["", "1", "11", "111", "56", "654"]
      bad  = ["1111", "x123y", "x123456y"]
      wanted = /^([1-6]){0,3}$/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 79: Simple lookaround (pos-ahead)

    describe "A correct program (Simple lookaround (pos-ahead))" do
      prog = <<-'END'
        match find "X" with "Y" end
      END

      good = ["XY"]
      bad  = ["X", "Y", "YX"]
      wanted = /(?=XY)X/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 80: Simple lookaround (neg-ahead)

    describe "A correct program (Simple lookaround (neg-ahead))" do
      prog = <<-'END'
        match find "X" without "Y" end
      END

      good = ["X", "YX"]
      bad  = ["XY", "Y"]
      wanted = /(?!XY)X/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 81: Simple lookaround (pos-behind)

    describe "A correct program (Simple lookaround (pos-behind))" do
      prog = <<-'END'
        match with "X" find "Y" end
      END

      good = ["XY"]
      bad  = ["YX", "Y", "X"]
      wanted = /(?<=X)Y/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 82: Simple lookaround (neg-behind)

    describe "A correct program (Simple lookaround (neg-behind))" do
      prog = <<-'END'
        match without "X" find "Y" end
      END

      good = ["aY", "Y"]
      bad  = ["XY", "X"]
      wanted = /(?<!X)Y/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 83: Positive lookahead

    describe "A correct program (Positive lookahead)" do
      prog = <<-'END'
        match find (3*D " dollars") with 3*D end
      END

      good = ["101 dollars"]
      bad  = ["102 pesos"]
      wanted = /(?=\d{3} dollars)\d{3}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 84: Negative lookahead

    describe "A correct program (Negative lookahead)" do
      prog = <<-'END'
        match find 3*D without " pesos" end
      END

      good = ["103 dollars", "104 euros"]
      bad  = ["105 pesos"]
      wanted = /(?!\d{3} pesos)\d{3}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 85: Positive lookbehind

    describe "A correct program (Positive lookbehind)" do
      prog = <<-'END'
        match with "USD" find 3*D end
      END

      good = ["USD106"]
      bad  = ["EUR107"]
      wanted = /(?<=USD)\d{3}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


    ### Test 86: Negative lookbehind

    describe "A correct program (Negative lookbehind)" do
      prog = <<-'END'
        match without "USD" find 3*D end
      END

      good = ["EUR108"]
      bad  = ["USD109"]
      wanted = /(?<!USD)\d{3}/

      myprog = Program.new(prog)
      parsed = nil

      it "should parse correctly"  do
        parsed = myprog.parseable?
        myprog.debug_bad_program_parse unless parsed
        parsed.should == true
      end

      rx = nil
      it "can be converted to a regex" do
        rx = myprog.regexp
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
      good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } 
      bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } 

      # Is compiled result valid?
      good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } 
      bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } 

      
      end


  end
