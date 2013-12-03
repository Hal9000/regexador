require './spec/testing'

describe Regexador do

  before(:all) do
    @parser = Regexador::Parser.new 
    @pattern = @parser.pattern
  end

  after(:each) do   # FIXME There must be a better way?
    if example.exception != nil
      puts "\n--- Failed to parse:"
      puts $prog
      puts "--- Result is:"
      puts @parser.parse_with_debug($prog)   # Why doesn't this work?
      puts "--- END"
    end
  end
  
  def self.program &block
    let(:code, &block)
    let(:program) { Program.new(code) }
    let(:regexp) { program.regexp }

    subject { program }
  end


  ### Test 1: Single char

  describe "Single char:" do
    $prog = prog = %q<match `x end>
    program { prog }

    good = ["abcx", "xyzb", "x"]
    bad  = ["yz", "", "ABC"]
    wanted = /x/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 2: Unicode codepoint

  describe "Unicode codepoint:" do
    $prog = prog = %q<match &20ac end>
    program { prog }

    good = ["€", "xyz€", "x€yz"]
    bad  = ["yz", "", "ABC"]
    wanted = /€/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 3: Manual international characters

  describe "Manual international characters:" do
    $prog = prog = %q<match "ö" end>
    program { prog }

    good = ["öffnen", "xyzö", "xöyz"]
    bad  = ["offnen", "yz", "", "ABC"]
    wanted = /ö/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 4: Simple range

  describe "Simple range:" do
    $prog = prog = %q<match `a-`f end>
    program { prog }

    good = ["alpha", "xyzb", "c"]
    bad  = ["xyz", "", "ABC"]
    wanted = /[a-f]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 5: Negated range

  describe "Negated range:" do
    $prog = prog = %q<match `c~`p end>
    program { prog }

    good = ["ab", "rst"]
    bad  = ["def", "mno", ""]
    wanted = /[^c-p]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 6: Negated char

  describe "Negated char:" do
    $prog = prog = %q<match ~`d end>
    program { prog }

    good = ["xyz", "123"]
    bad  = ["d", "dd"]
    wanted = /[^d]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 7: POSIX class

  describe "POSIX class:" do
    $prog = prog = %q<match %alnum end>
    program { prog }

    good = ["abc365", "237", "xyz"]
    bad  = ["---", ":,.-"]
    wanted = /[[:alnum:]]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 8: Simple char class

  describe "Simple char class:" do
    $prog = prog = %q<match 'prstu' end>
    program { prog }

    good = ["du", "ppp", "sr"]
    bad  = ["abc", "xyz"]
    wanted = /[prstu]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 9: Negated char class

  describe "Negated char class:" do
    $prog = prog = %q<match ~'ilmnop' end>
    program { prog }

    good = ["abacus", "peccata", "hydrogen"]
    bad  = ["oil", "pill"]
    wanted = /[^ilmnop]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 10: Predef Beginning of string

  describe "Predef Beginning of string:" do
    $prog = prog = %q<match BOS end>
    program { prog }

    good = [""]
    bad  = []
    wanted = /^/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 11: Predef End of string

  describe "Predef End of string:" do
    $prog = prog = %q<match EOS end>
    program { prog }

    good = [""]
    bad  = []
    wanted = /$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 12: Predef Word boundary

  describe "Predef Word boundary:" do
    $prog = prog = %q<match WB end>
    program { prog }

    good = ["xyz"]
    bad  = ["", "---"]
    wanted = /\b/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 13: Simple string

  describe "Simple string:" do
    $prog = prog = %q<match "xyz" end>
    program { prog }

    good = ["xyz", "abcxyzdef"]
    bad  = ["abc", "xydefz"]
    wanted = /xyz/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 14: Single-bounded repetition

  describe "Single-bounded repetition:" do
    $prog = prog = %q<match 5 * "xyz" end>
    program { prog }

    good = ["xyzxyzxyzxyzxyz"]
    bad  = ["xyzxyzxyzxyz"]
    wanted = /(xyz){5}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 15: Double-bounded repetition

  describe "Double-bounded repetition:" do
    $prog = prog = %q<match 3,4 * %alpha end>
    program { prog }

    good = ["abc", "abcd"]
    bad  = ["ab", "x"]
    wanted = /([[:alpha:]]){3,4}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 16: any-qualifier

  describe "any-qualifier:" do
    $prog = prog = %q<match any "abc" end>
    program { prog }

    good = ["", "abc", "abcabc", "xyz"]
    bad  = []
    wanted = /(abc)*/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 17: many-qualifier

  describe "many-qualifier:" do
    $prog = prog = %q<match many "def" end>
    program { prog }

    good = ["def", "defdef", "defdefdef"]
    bad  = ["", "de", "xyz"]
    wanted = /(def)+/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 18: nocase-qualifier

  describe "nocase-qualifier:" do
    $prog = prog = %q<match nocase "ghi" end>
    program { prog }

    good = ["ghi", "GHI", "abGhicd"]
    bad  = ["", "gh", "abc"]
    wanted = /((?i)ghi)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 19: maybe-qualifier

  describe "maybe-qualifier:" do
    $prog = prog = %q<match maybe "ghi" end>
    program { prog }

    good = ["", "ghi", "abghicd", "gh"]
    bad  = []
    wanted = /(ghi)?/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 20: Simple concatenation of two strings

  describe "Simple concatenation of two strings:" do
    $prog = prog = %q<match "abc" "def" end>
    program { prog }

    good = ["abcdefghi", "xyzabcdef"]
    bad  = ["", "abcxyzdef"]
    wanted = /abcdef/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 21: Concat of string and char class

  describe "Concat of string and char class:" do
    $prog = prog = %q<match "abc"'def' end>
    program { prog }

    good = ["abcd", "abce"]
    bad  = ["", "abcx"]
    wanted = /abc[def]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 22: Simple alternation

  describe "Simple alternation:" do
    $prog = prog = %q<match "abc" | "def" end>
    program { prog }

    good = ["abc", "xyzabc123", "xdefy"]
    bad  = ["", "abde", "ab c d ef"]
    wanted = /(abc|def)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 23: Alternation of concatenations

  describe "Alternation of concatenations:" do
    $prog = prog = %q<match "ab" "c" | "d" "ef" end>
    program { prog }

    good = ["abc", "xyzabc123", "xdefy"]
    bad  = ["", "abde", "ab c d ef"]
    wanted = /(abc|def)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 24: Precedence of concatenation over alternation

  describe "Precedence of concatenation over alternation:" do
    $prog = prog = %q<match "a" "b" | "c" end>
    program { prog }

    good = ["ab", "c"]
    bad  = ["b", "a", "d"]
    wanted = /(ab|c)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 25: Precedence of parens over concatenation

  describe "Precedence of parens over concatenation:" do
    $prog = prog = %q<match "a" ("b" | "c") end>
    program { prog }

    good = ["ab", "ac"]
    bad  = ["a", "b", "c"]
    wanted = /a(b|c)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 26: Anchors and alternation

  describe "Anchors and alternation:" do
    $prog = prog = %q<match BOS "x" | "y" EOS end>
    program { prog }

    good = ["xabc", "abcy"]
    bad  = ["abc", "abcx", "yabc", "axb", "ayb", "axyb"]
    wanted = /(^x|y$)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 27: Anchors, alternation, parens

  describe "Anchors, alternation, parens:" do
    $prog = prog = %q<match BOS ("x" | "y") EOS end>
    program { prog }

    good = ["x", "y"]
    bad  = ["abc", "abcx", "yabc", "xabc", "abcy"]
    wanted = /^(x|y)$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 28: Parens, concatenation, alternation

  describe "Parens, concatenation, alternation:" do
    $prog = prog = %q<match BOS ((maybe `0) `1-`9 | `1 D2) EOS end>
    program { prog }

    good = ["01", "09", "12"]
    bad  = ["0", "00", "13"]
    wanted = /^((0)?[1-9]|1[0-2])$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 29: Single backtick char

  describe "Single backtick char:" do
    $prog = prog = %q<match `` end>
    program { prog }

    good = ["`", "this is a tick: `", "tock ` tock"]
    bad  = ["", "abc"]
    wanted = /`/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 30: Single backslash char

  describe "Single backslash char:" do
    $prog = prog = %q<match `\ end>
    program { prog }

    good = ["\\", "trying \\n", "and \\b also"]
    bad  = ["\n", "\b", "neither \r nor \t"]
    wanted = /\\/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 31: Empty string

  describe "Empty string:" do
    $prog = prog = %q<match "" end>
    program { prog }

    good = ["", "abc"]
    bad  = []
    wanted = //

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 32: Simple char class

  describe "Simple char class:" do
    $prog = prog = %q<match 'abcdef' end>
    program { prog }

    good = ["there's a cat here", "item c"]
    bad  = ["", "proton"]
    wanted = /[abcdef]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 33: Simple one-char class

  describe "Simple one-char class:" do
    $prog = prog = %q<match 'x' end>
    program { prog }

    good = ["x", "uvwxyz"]
    bad  = ["", "abc"]
    wanted = /[x]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 34: Alternation of range and class

  describe "Alternation of range and class:" do
    $prog = prog = %q<match `a-`f | 'xyz' end>
    program { prog }

    good = ["a", "x", "z", "c"]
    bad  = ["", "jkl", "gw"]
    wanted = /([a-f]|[xyz])/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 35: Alternation of range and maybe-clause

  describe "Alternation of range and maybe-clause:" do
    $prog = prog = %q<match `1-`6| maybe "#" end>
    program { prog }

    good = ["", "1#", "1", " 2# abc"]
    bad  = []
    wanted = /([1-6]|(\#)?)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 36: Four-way alternation

  describe "Four-way alternation:" do
    $prog = prog = %q<match `a | `b|`c|`d end>
    program { prog }

    good = ["xyza", "xybz", "xcyz", "dxyz"]
    bad  = ["", "every", "ghijk"]
    wanted = /(a|b|c|d)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 37: Concatenation of range and class

  describe "Concatenation of range and class:" do
    $prog = prog = %q<match `a-`f 'xyz' end>
    program { prog }

    good = ["ax", "fz", "cy"]
    bad  = ["zf", "xa", "gz", "hp", "mx"]
    wanted = /[a-f][xyz]/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 38: Concat of strings and maybe-clause

  describe "Concat of strings and maybe-clause:" do
    $prog = prog = %q<match "this" "that" maybe "other" end>
    program { prog }

    good = ["thisthat", "thisthatother", "abc thisthat xyz", "abc thisthatother xyz"]
    bad  = ["", "abc", "this that", "this that other"]
    wanted = /thisthat(other)?/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 39: Simple repetition of class

  describe "Simple repetition of class:" do
    $prog = prog = %q<match 3 * 'xyz' end>
    program { prog }

    good = ["xyz", "xxx", "yzy", "xyzzy123"]
    bad  = ["", "abc", "xy", "axy", "xyb", "axyb"]
    wanted = /([xyz]){3}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 40: Simple repetition of range

  describe "Simple repetition of range:" do
    $prog = prog = %q<match 4 * `1-`6 end>
    program { prog }

    good = ["1111", "1234", "abc 6543 def"]
    bad  = ["", "abc", "123", "123 4"]
    wanted = /([1-6]){4}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 41: Complex repetition of char

  describe "Complex repetition of char:" do
    $prog = prog = %q<match 3,5 * (`a) end>
    program { prog }

    good = ["aaa", "aaaa", "aaaaa", "xaaay", "aaaaaaa"]
    bad  = ["", "abc", "aa"]
    wanted = /(a){3,5}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 42: Complex repetition of parenthesized class

  describe "Complex repetition of parenthesized class:" do
    $prog = prog = %q<match 4,7 * ('xyz') end>
    program { prog }

    good = ["xxxx", "yyyy", "xyzy", "xyzzy", "zyzzyva", "xyzxyz", "xyzxyzx", "xyzxyzxyzxyz"]
    bad  = ["", "abc", "x", "xx", "xxx", "xyz xy"]
    wanted = /([xyz]){4,7}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 43: Complex repetition of parenthesized range

  describe "Complex repetition of parenthesized range:" do
    $prog = prog = %q<match 0,3 * (`1-`6) end>
    program { prog }

    good = ["", "1", "11", "111", "56", "654", "1111", "x123y", "x123456y"]
    bad  = []
    wanted = /([1-6]){0,3}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 44: Single char (anchored)

  describe "Single char (anchored):" do
    $prog = prog = %q<match BOS `x EOS end>
    program { prog }

    good = ["x"]
    bad  = ["yz", "", "ABC"]
    wanted = /^x$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 45: Simple range (anchored)

  describe "Simple range (anchored):" do
    $prog = prog = %q<match BOS `a-`f EOS end>
    program { prog }

    good = ["a", "b", "c", "d", "e", "f"]
    bad  = ["xyz", "", "ABC"]
    wanted = /^[a-f]$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 46: Negated range (anchored)

  describe "Negated range (anchored):" do
    $prog = prog = %q<match BOS `c~`p EOS end>
    program { prog }

    good = ["a", "r"]
    bad  = ["def", "mno", ""]
    wanted = /^[^c-p]$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 47: Negated char (anchored)

  describe "Negated char (anchored):" do
    $prog = prog = %q<match BOS ~`d EOS end>
    program { prog }

    good = ["x", "1"]
    bad  = ["d", "dd", "abc"]
    wanted = /^[^d]$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 48: POSIX class (anchored)

  describe "POSIX class (anchored):" do
    $prog = prog = %q<match BOS %alnum EOS end>
    program { prog }

    good = ["c", "2"]
    bad  = ["", "abc", "123", "-", ":", ",", "."]
    wanted = /^[[:alnum:]]$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 49: Simple char class (anchored)

  describe "Simple char class (anchored):" do
    $prog = prog = %q<match BOS 'prstu' EOS end>
    program { prog }

    good = ["u", "p", "s"]
    bad  = ["", "abc", "x"]
    wanted = /^[prstu]$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 50: Negated char class (anchored)

  describe "Negated char class (anchored):" do
    $prog = prog = %q<match BOS ~'ilmnop' EOS end>
    program { prog }

    good = ["a", "e", "h"]
    bad  = ["o", "i", "l"]
    wanted = /^[^ilmnop]$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 51: Simple string (anchored)

  describe "Simple string (anchored):" do
    $prog = prog = %q<match BOS "xyz" EOS end>
    program { prog }

    good = ["xyz"]
    bad  = ["", "abc", "abcxyzdef", "xydefz"]
    wanted = /^xyz$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 52: Single-bounded repetition (anchored)

  describe "Single-bounded repetition (anchored):" do
    $prog = prog = %q<match BOS 5 * "xyz" EOS end>
    program { prog }

    good = ["xyzxyzxyzxyzxyz"]
    bad  = ["xyzxyzxyzxyz", "abcxyzxyzxyzxyz", "xyzxyzxyzxyzabc"]
    wanted = /^(xyz){5}$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 53: Double-bounded repetition (anchored)

  describe "Double-bounded repetition (anchored):" do
    $prog = prog = %q<match BOS 3,4 * %alpha EOS end>
    program { prog }

    good = ["abc", "abcd"]
    bad  = ["", "ab", "x", "abcde"]
    wanted = /^([[:alpha:]]){3,4}$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 54: any-qualifier (anchored)

  describe "any-qualifier (anchored):" do
    $prog = prog = %q<match BOS any "abc" EOS end>
    program { prog }

    good = ["", "abc", "abcabc", "abcabcabc"]
    bad  = ["ab", "abcab", "xyz"]
    wanted = /^(abc)*$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 55: many-qualifier (anchored)

  describe "many-qualifier (anchored):" do
    $prog = prog = %q<match BOS many "def" EOS end>
    program { prog }

    good = ["def", "defdef", "defdefdef"]
    bad  = ["", "d", "de", "defd", "xyz"]
    wanted = /^(def)+$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 56: maybe-qualifier (anchored)

  describe "maybe-qualifier (anchored):" do
    $prog = prog = %q<match BOS maybe "ghi" EOS end>
    program { prog }

    good = ["", "ghi"]
    bad  = ["abghicd", "gh"]
    wanted = /^(ghi)?$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 57: Simple concatenation of two strings (anchored)

  describe "Simple concatenation of two strings (anchored):" do
    $prog = prog = %q<match BOS "abc" "def" EOS end>
    program { prog }

    good = ["abcdef"]
    bad  = ["", "abcd", "xyzabcdef", "abcxyzdef", "abcdefxyz"]
    wanted = /^abcdef$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 58: Concat of string and char class (anchored)

  describe "Concat of string and char class (anchored):" do
    $prog = prog = %q<match BOS "abc" 'def' EOS end>
    program { prog }

    good = ["abcd", "abce", "abcf"]
    bad  = ["", "ab", "abc", "abcx"]
    wanted = /^abc[def]$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 59: Simple alternation (anchored)

  describe "Simple alternation (anchored):" do
    $prog = prog = %q<match BOS ("abc" | "def") EOS end>
    program { prog }

    good = ["abc", "def"]
    bad  = ["", "abde", "ab c d ef", "xdefy"]
    wanted = /^(abc|def)$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 60: Alternation of concatenations (anchored)

  describe "Alternation of concatenations (anchored):" do
    $prog = prog = %q<match BOS ("ab" "c" | "d" "ef") EOS end>
    program { prog }

    good = ["abc", "def"]
    bad  = ["", "abde", "ab c d ef", "xdefy"]
    wanted = /^(abc|def)$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 61: Precedence of concatenation over alternation (anchored)

  describe "Precedence of concatenation over alternation (anchored):" do
    $prog = prog = %q<match BOS ("a" "b" | "c") EOS end>
    program { prog }

    good = ["ab", "c"]
    bad  = ["", "b", "a", "d", "abc", "abcde"]
    wanted = /^(ab|c)$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 62: Precedence of parens over concatenation (anchored)

  describe "Precedence of parens over concatenation (anchored):" do
    $prog = prog = %q<match BOS "a" ("b" | "c") EOS end>
    program { prog }

    good = ["ab", "ac"]
    bad  = ["a", "b", "c", "abc", "abx", "bac"]
    wanted = /^a(b|c)$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 63: Anchors and alternation (anchored)

  describe "Anchors and alternation (anchored):" do
    $prog = prog = %q<match BOS "x" | "y" EOS end>
    program { prog }

    good = ["xabc", "abcy"]
    bad  = ["abc", "abcx", "yabc", "axb", "ayb", "axyb"]
    wanted = /(^x|y$)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 64: Parens, concatenation, alternation (anchored)

  describe "Parens, concatenation, alternation (anchored):" do
    $prog = prog = %q<match BOS ((maybe `0) `1-`9 | `1 D2) EOS end>
    program { prog }

    good = ["01", "09", "12"]
    bad  = ["0", "00", "13"]
    wanted = /^((0)?[1-9]|1[0-2])$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 65: Single backtick char (anchored)

  describe "Single backtick char (anchored):" do
    $prog = prog = %q<match BOS `` EOS end>
    program { prog }

    good = ["`"]
    bad  = ["", "abc", "this is a tick: `", "tock ` tock"]
    wanted = /^`$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 66: Single backslash char (anchored)

  describe "Single backslash char (anchored):" do
    $prog = prog = %q<match BOS `\ EOS end>
    program { prog }

    good = ["\\"]
    bad  = ["\n", "\b", "neither \r nor \t", "trying \\n", "and \\b also"]
    wanted = /^\\$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 67: Empty string (anchored)

  describe "Empty string (anchored):" do
    $prog = prog = %q<match BOS "" EOS end>
    program { prog }

    good = [""]
    bad  = ["abc"]
    wanted = /^$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 68: Simple one-char class (anchored)

  describe "Simple one-char class (anchored):" do
    $prog = prog = %q<match BOS 'x' EOS end>
    program { prog }

    good = ["x"]
    bad  = ["", "abc", "uvwxyz"]
    wanted = /^[x]$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 69: Alternation of range and class (anchored)

  describe "Alternation of range and class (anchored):" do
    $prog = prog = %q<match BOS (`a-`f | 'xyz') EOS end>
    program { prog }

    good = ["a", "x", "z", "c"]
    bad  = ["", "ab", "abc", "xy", "jkl", "gw"]
    wanted = /^([a-f]|[xyz])$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 70: Alternation of range and maybe-clause (anchored)

  describe "Alternation of range and maybe-clause (anchored):" do
    $prog = prog = %q<match BOS (`1-`6| maybe "#") EOS end>
    program { prog }

    good = ["", "1", "#", "6"]
    bad  = ["55", "###"]
    wanted = /^([1-6]|(\#)?)$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 71: Four-way alternation (anchored)

  describe "Four-way alternation (anchored):" do
    $prog = prog = %q<match BOS (`a | `b|`c|`d) EOS end>
    program { prog }

    good = ["a", "b", "c", "d"]
    bad  = ["", "ab", "every", "ghijk"]
    wanted = /^(a|b|c|d)$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 72: Concatenation of range and class (anchored)

  describe "Concatenation of range and class (anchored):" do
    $prog = prog = %q<match BOS `a-`f 'xyz' EOS end>
    program { prog }

    good = ["ax", "fz", "cy"]
    bad  = ["axe", "fz123", "zf", "xa", "gz", "hp", "mx"]
    wanted = /^[a-f][xyz]$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 73: Concat of strings and maybe-clause (anchored)

  describe "Concat of strings and maybe-clause (anchored):" do
    $prog = prog = %q<match BOS "this" "that" maybe "other" EOS end>
    program { prog }

    good = ["thisthat", "thisthatother"]
    bad  = ["", "abc", "this that", "this that other", "abc thisthat xyz", "abc thisthatother xyz"]
    wanted = /^thisthat(other)?$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 74: Simple repetition of class (anchored)

  describe "Simple repetition of class (anchored):" do
    $prog = prog = %q<match BOS 3 * 'xyz' EOS end>
    program { prog }

    good = ["xyz", "xxx", "yzy"]
    bad  = ["", "abc", "xy", "axy", "xyb", "axyb", "xyzzy123"]
    wanted = /^([xyz]){3}$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 75: Simple repetition of range (anchored)

  describe "Simple repetition of range (anchored):" do
    $prog = prog = %q<match BOS 4 * `1-`6 EOS end>
    program { prog }

    good = ["1111", "1234"]
    bad  = ["", "abc", "123", "123 4", "abc 6543 def"]
    wanted = /^([1-6]){4}$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 76: Complex repetition of char (anchored)

  describe "Complex repetition of char (anchored):" do
    $prog = prog = %q<match BOS 3,5 * (`a) EOS end>
    program { prog }

    good = ["aaa", "aaaa", "aaaaa"]
    bad  = ["", "abc", "aa", "xaaay", "aaaaaaa"]
    wanted = /^(a){3,5}$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 77: Complex repetition of parenthesized class (anchored)

  describe "Complex repetition of parenthesized class (anchored):" do
    $prog = prog = %q<match BOS 4,7 * ('xyz') EOS end>
    program { prog }

    good = ["xxxx", "yyyy", "xyzy", "xyzzy", "xyzxyz", "xyzxyzx"]
    bad  = ["", "abc", "x", "xx", "xxx", "xyz xy", "xyzxyzxyzxyz", "zyzzyva"]
    wanted = /^([xyz]){4,7}$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 78: Complex repetition of parenthesized range (anchored)

  describe "Complex repetition of parenthesized range (anchored):" do
    $prog = prog = %q<match BOS 0,3 * (`1-`6) EOS end>
    program { prog }

    good = ["", "1", "11", "111", "56", "654"]
    bad  = ["1111", "x123y", "x123456y"]
    wanted = /^([1-6]){0,3}$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 79: Simple lookaround (pos-ahead)

  describe "Simple lookaround (pos-ahead):" do
    $prog = prog = %q<match find "X" with "Y" end>
    program { prog }

    good = ["XY"]
    bad  = ["X", "Y", "YX"]
    wanted = /(?=XY)X/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 80: Simple lookaround (neg-ahead)

  describe "Simple lookaround (neg-ahead):" do
    $prog = prog = %q<match find "X" without "Y" end>
    program { prog }

    good = ["X", "YX"]
    bad  = ["XY", "Y"]
    wanted = /(?!XY)X/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 81: Simple lookaround (pos-behind)

  describe "Simple lookaround (pos-behind):" do
    $prog = prog = %q<match with "X" find "Y" end>
    program { prog }

    good = ["XY"]
    bad  = ["YX", "Y", "X"]
    wanted = /(?<=X)Y/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 82: Simple lookaround (neg-behind)

  describe "Simple lookaround (neg-behind):" do
    $prog = prog = %q<match without "X" find "Y" end>
    program { prog }

    good = ["aY", "Y"]
    bad  = ["XY", "X"]
    wanted = /(?<!X)Y/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 83: Positive lookahead

  describe "Positive lookahead:" do
    $prog = prog = %q<match find (3*D " dollars") with 3*D end>
    program { prog }

    good = ["101 dollars"]
    bad  = ["102 pesos"]
    wanted = /(?=\d{3} dollars)\d{3}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 84: Negative lookahead

  describe "Negative lookahead:" do
    $prog = prog = %q<match find 3*D without " pesos" end>
    program { prog }

    good = ["103 dollars", "104 euros"]
    bad  = ["105 pesos"]
    wanted = /(?!\d{3} pesos)\d{3}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 85: Positive lookbehind

  describe "Positive lookbehind:" do
    $prog = prog = %q<match with "USD" find 3*D end>
    program { prog }

    good = ["USD106"]
    bad  = ["EUR107"]
    wanted = /(?<=USD)\d{3}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 86: Negative lookbehind

  describe "Negative lookbehind:" do
    $prog = prog = %q<match without "USD" find 3*D end>
    program { prog }

    good = ["EUR108"]
    bad  = ["USD109"]
    wanted = /(?<!USD)\d{3}/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 87: Simple use of two vars

  describe "Simple use of two vars:" do
    $prog = prog = <<-'END'
    var1 = "abc"
    var2 = "def"
    match var1 var2 end
    END
    program { prog }

    good = ["abcdefghi", "xyzabcdef"]
    bad  = ["", "abcxyzdef"]
    wanted = /abcdef/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 88: Multiline match with two vars

  describe "Multiline match with two vars:" do
    $prog = prog = <<-'END'
      var1 = "abc"
      var2 = "def"
        
      # Test a blank line and comment as well.
 
      match   # multiline match with comment
        var1
        var2
      end
    END
    program { prog }

    good = ["abcdefghi", "xyzabcdef"]
    bad  = ["", "abcxyzdef"]
    wanted = /abcdef/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 89: IPv4 address

  describe "IPv4 address:" do
    $prog = prog = <<-'END'
      dot = "."
      num = "25" D5 | `2 D4 D | maybe D1 1,2*D
      match BOS num dot num dot num dot num EOS end
    END
    program { prog }

    good = ["127.0.0.1", "255.254.93.22", "255.254.93.22"]
    bad  = ["", "7.8.9", "3.4.5.6.7", "1.2.3.256"]
    wanted = /^(25[0-5]|2[0-4]\d|([01])?(\d){1,2})\.(25[0-5]|2[0-4]\d|([01])?(\d){1,2})\.(25[0-5]|2[0-4]\d|([01])?(\d){1,2})\.(25[0-5]|2[0-4]\d|([01])?(\d){1,2})$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 90: Identifying credit cards

  describe "Identifying credit cards:" do
    $prog = prog = <<-'END'
      # Warning: This one may have errors!
      visa     = `4 12*D maybe 3*D
      mc       = `5 D5 14*D
      discover = `6 ("011" | `5 2*D) 12*D
      amex     = `3 '47' 13*D
      diners   = `3 (`0 D5 | '68' D) 11*D
      jcb      = ("2131"|"1800"|"35" 3*D) 11*D

      match visa | mc | discover | amex | diners | jcb end
    END
    program { prog }

    good = []
    bad  = []
    wanted = /(4(\d){12}((\d){3})?|5[0-5](\d){14}|6(011|5(\d){2})(\d){12}|3[47](\d){13}|3(0[0-5]|[68]\d)(\d){11}|(2131|1800|35(\d){3})(\d){11})/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 91: Matching US phone num (with captures)

  describe "Matching US phone num (with captures):" do
    $prog = prog = <<-'END'
      match
        @area_code = 3 * D
        `-
        @prefix = 3*D
        `-
        @last4 = 4*D
      end
    END
    program { prog }

    good = ["601-555-2345", "call me at 888-425-9000"]
    bad  = ["888-HAL-9000", "800.237.1234"]
    wanted = /(?<area_code>(\d){3})\-(?<prefix>(\d){3})\-(?<last4>(\d){4})/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 92: Matching a clock time, 12/24 hrs

  describe "Matching a clock time, 12/24 hrs:" do
    $prog = prog = <<-'END'
      hr12 = (maybe `0) `1-`9 | `1 D2
      hr24 = (maybe `0) D | `1 D | `2 D3
      sep  = `: | `.
      min  = D5 D9
      sec  = D5 D9
      ampm = (maybe SPACE) ("am" | "pm")
      time12 = hr12 sep min maybe (sep sec) maybe ampm
      time24 = hr24 sep min maybe (sep sec)
      match BOS (time12 | time24) EOS end
    END
    program { prog }

    good = ["12:34", "1:23", "5:14pm", "19:43", "1:23:45", "1:23:45 pm", "7:43 pm", "8:32:45", "8.34", "8.34 pm", "8.34.45"]
    bad  = ["", "abc", "24:30", "25:30", "19:43 pm", "5:14  pm"]
    wanted = /^(((0)?[1-9]|1[0-2])(:|\.)[0-5]\d((:|\.)[0-5]\d)?(( )?(am|pm))?|((0)?\d|1\d|2[0-3])(:|\.)[0-5]\d((:|\.)[0-5]\d)?)$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 93: Using nocase

  describe "Using nocase:" do
    $prog = prog = %q<match BOS "abc" nocase "def" "ghi" EOS end>
    program { prog }

    good = ["abcdefghi", "abcDEFghi", "abcdEfghi"]
    bad  = ["", "x", "xabcdefghi", "abcdefghix", "aBcdefghi", "abcdefGhi", "abCdefghI", "abCdEfghI"]
    wanted = /^abc((?i)def)ghi$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 94: Var used in simple repetition

  describe "Var used in simple repetition:" do
    $prog = prog = <<-'END'
      n = 3
      match BOS n * `x EOS end
    END
    program { prog }

    good = ["xxx"]
    bad  = ["", "x", "xx x", "xxxx"]
    wanted = /^(x){3}$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 95: Var used in complex repetition

  describe "Var used in complex repetition:" do
    $prog = prog = <<-'END'
      m = 4
      n = 6
      match BOS m,n * `x EOS end
    END
    program { prog }

    good = ["xxxx", "xxxxx", "xxxxxx"]
    bad  = ["", "x", "xx x", "xxx", "xxxxxxx"]
    wanted = /^(x){4,6}$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 96: Using Unicode codepoint again

  describe "Using Unicode codepoint again:" do
    $prog = prog = <<-'END'
      euro = &20ac
      price = (euro | "$") SPACE many D maybe ("." 2*D)
      match BOS price EOS end
    END
    program { prog }

    good = ["€ 237", "$ 237", "€ 23.45", "€ 0.25"]
    bad  = ["", "x", "€", "€ ", "€  237", "$  237", "€ 23.456"]
    wanted = /^(€|\$) (\d)+(\.(\d){2})?$/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 97: Using within (1)

  describe "Using within (1):" do
    $prog = prog = %q<match within `/ end>
    program { prog }

    good = ["There is a /slash-delimited string/ here."]
    bad  = ["No such string here."]
    wanted = /(\/.*?\/)/

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


  ### Test 98: Using escaping (1)

  describe "Using escaping (1):" do
    $prog = prog = %q<match escaping `/ end>
    program { prog }

    good = ["This is /slash-delimited but \\/with embedded slashes \\/ also /."]
    bad  = ["No such string here."]
    wanted = /\/|[^\/]*?\//

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.to_s.should == wanted.to_s
    end

    # Check sanity: Is test valid?
    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }
    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }

    # Is compiled result valid?
    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }
    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }
  end   # end of test


end
