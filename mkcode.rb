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

    describe "A one-pattern program (<%= desc %>)" do
      prog = <<-END
        <%= pat %>
      END

      good = <%= good.inspect %>
      bad  = <%= bad.inspect %>
      wanted = <%= wanted.inspect %>

      it("should parse correctly") { @parser.should parse(prog) }

      rx = nil
      it "can be converted to a regex" do
        rx = Regexador.new(prog).to_regex
        rx.class.should == Regexp
      end

      # Check sanity: Is test valid?
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
exit


=begin
  
# $debug = true
  
  @programs.each do |x|
    desc, prog, wanted, good, bad = 
      x.description, x.program, x.regex, x.good, x.bad
    describe "A complete program (#{desc})" do
      begin
        it("can be parsed") { @parser.parse_with_debug(prog).succeeds }
        pattern = Regexador.new(prog)
        rx = pattern.to_regex
        it("can be converted to a regex") { rx.class.should == Regexp }
        good.each {|str| it("should match #{str.inspect}") { rx.should match(str) } }
        bad.each  {|str| it("should not match #{str.inspect}") { rx.should_not match(str) } }
        good.each {|str| it("should natively match #{str.inspect}") { (!!(pattern =~ str)).should == true } }
        bad.each  {|str| it("should not natively match #{str.inspect}") { (!!(pattern =~ str)).should == false } }
        it("yields the expected regex") { (rx.to_s.should == wanted.to_s) if wanted }
        # Sanity check... does the expected regex really match properly?
        good.each {|str| it("has an expected regex matching #{str.inspect}") { wanted.should =~ str } }
        bad.each  {|str| it("has an expected regex not matching #{str.inspect}") { wanted.should_not =~ str } }
      rescue => err
        puts "--- ERROR: #{err}"
        puts "--- Description = '#{desc}'"
        puts err.backtrace
      end
    end 
  end

  @captures.each do |x|
    desc, prog, wanted, examples = 
      x.description, x.program, x.regex, x.examples
    describe "A program with captures (#{desc})" do
      begin
        it("can be parsed") { @parser.parse(prog).succeeds }
  
        pattern = Regexador.new(prog)
        rx = pattern.to_regex
        it("can be converted to a regex") { rx.class.should == Regexp }
  
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
        it("yields the expected regex") { (rx.to_s.should == wanted.to_s) if wanted }
      rescue => err
        puts "Error: #{err}"
      end
    end 
  end

end

describe Regexador::Transform do
  describe Regexador::Transform::StringNode do
    let(:sn) { Regexador::Transform::StringNode.new('.string.') }

    it 'converts to regexp escaped strings' do
      sn.to_s.should == '\.string\.'
    end
  end
end


=end
