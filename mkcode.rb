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
@captures  = YAML.load(File.read("spec/captures.yaml"))

text = <<-EOF
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
      tree = tree[:alternation] \
        if tree.size == 1 && tree.keys.first == :alternation
      tree = tree[:sequence].first \
        if tree.size == 1 && tree.keys.first == :sequence
      tree
    end

    def parse
      tree = @parser.parse(@full_program)
    end

    def debug_bad_program_parse
      @parser.parse(@full_program)
      atree = nil
    rescue Parslet::ParseFailed => error
      atree = error.cause.ascii_tree.split("\n")
      lchar = /at line (\d+) char (\d+).$/
      fname = rand(10**5).to_s + ".tree"
      File.open(fname, "w") {|f| f.puts @full_program + "\n" + atree.join("\n") }
      puts "See file: " + fname
      return
      # FIXME bad logic below
      begin
        atree.map! do |line|
          line.gsub!(/`- |\|- |\|  /, "   ")
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
EOF

num = 0

@oneliners.each {|x| x.program = "match #{x.program} end" }

programs = @oneliners + @programs

@oneliners.each do |x|
  num += 1
  desc, pat, wanted, good, bad, examples = 
    x.description, x.program, x.regex, x.good, x.bad, x.examples
  piece = <<-ERB

    ### Test <%= num %>: <%= desc %>

    describe "A correct program (<%= desc %>)" do
      prog = <<-'END'
        <%= pat %>
      END

      good = <%= good.inspect %>
      bad  = <%= bad.inspect %>
      wanted = <%= wanted.inspect %>

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

      <% if good or bad %># Check sanity: Is test valid?<% end %>
      <% if good %>good.each {|str| it('has expected regex matching ' + str.inspect) { wanted.should =~ str } } <% end %>
      <% if bad %>bad.each  {|str| it('has expected regex NOT matching ' + str.inspect) { wanted.should_not =~ str } } <% end %>

      # Is compiled result valid?
      <% if good %>good.each {|str| it('should match ' + str.inspect) { rx.should =~ str } } <% end %>
      <% if bad %>bad.each  {|str| it('should NOT match ' + str.inspect) { rx.should_not =~ str } } <% end %>

      <% if examples %># Are there capture examples to test?
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
      <% end %>
      end

  ERB

  text << ERB.new(piece).result(binding)
end

text << "\n  end"

puts text
