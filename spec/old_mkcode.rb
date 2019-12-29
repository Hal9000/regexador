require 'yaml'
require 'erb'

class Program
  attr_accessor :description, :program, :regex, :good, :bad, :examples
end

Capture = Program

def escape(str)
  str.inspect[1..-1].gsub(/\\n/, "\n")
end

@oneliners = YAML.load(File.read("spec/oneliners.yaml"))
@programs  = YAML.load(File.read("spec/programs.yaml"))

text = <<-EOF
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

EOF

def sanity_check(good, bad)
  piece2 = ""
  if good or bad
    piece2 = "\n    # Check sanity: Is test valid?\n"
    if good
      piece2 << "    good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } }"
      piece2 << "\n"
    end
    if bad 
      piece2 << "    bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } }"
      piece2 << "\n"
    end
  end
  piece2
end

def result_check(good, bad)
  piece3 = "\n    # Is compiled result valid?\n"
  if good 
    piece3 << "    good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } }"
    piece3 << "\n"
  end
  if bad 
    piece3 << "    bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } }"
    piece3 << "\n"
  end
  piece3
end

num = 0

@oneliners.each {|x| x.program = "match #{x.program} end" }

programs = @oneliners + @programs

programs.each do |x|
  num += 1
  desc, prog, wanted, good, bad, examples = 
    x.description, x.program, x.regex, x.good, x.bad, x.examples
  assign_prog = if prog.split("\n").size == 1
    "prog = %q<#{prog.chomp}>"
  else
    "prog = <<-'END'\n    #{prog.gsub("\\n", "\\n    ")}\n  END"
  end
  piece1 = <<-ERB

  ### Test <%= num %>: <%= desc %>

  describe "<%= desc %>:" do
    <%= assign_prog %>
    program { prog }

    good = <%= good.inspect %>
    bad  = <%= bad.inspect %>
    wanted = <%= wanted.inspect %>

    it { should be_parseable }

    rx = nil
    it "can be converted to a regex" do
      rx = regexp
      rx.class.should == Regexp
      rx.should == wanted
    end
ERB

  piece2 = sanity_check(good, bad)
  piece3 = result_check(good, bad)

  piece4 = ""
  piece5 = "  end   # end of test\n\n"

  pieces = piece1 + piece2 + piece3 + piece4 + piece5
  text << ERB.new(pieces).result(binding)
end

text << "\nend"

puts text

