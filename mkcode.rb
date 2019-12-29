require 'yaml'

class Program
  attr_accessor :description, :program, :regex, :good, :bad, :examples
end

def escape(str)
  str.inspect[1..-1].gsub(/\\n/, "\n")
end


# Main...

@oneliners = YAML.load(File.read("spec/oneliners.yaml"))
@programs  = YAML.load(File.read("spec/programs.yaml"))

text = <<-RUBY
$LOAD_PATH << "." << "./lib"

require 'regexador'

require "minitest/autorun"


class TestRegexador < Minitest::Test

RUBY

def sanity_check(good, bad)
  fragment = ""
  return fragment unless good || bad
  fragment = <<-RUBY
      # Check sanity: Is test valid?
  RUBY

  if good
    fragment << <<-RUBY
      good.each {|str| assert regex =~ str, "#{'#{str.inspect}'}: no match!" }
    RUBY
  end

  if bad 
    fragment << <<-RUBY
      bad.each  {|str| refute regex =~ str, "#{'#{str.inspect}'}: unexpected match!" }
    RUBY
  end

  fragment
end

def result_check(good, bad)
  fragment = ""
  return fragment unless good || bad

  fragment = <<-RUBY
      # Is compiled result valid?
  RUBY

  if good 
    fragment << <<-RUBY
      good.each {|str| assert rx =~ str, "Did not match: #{'#{str.inspect}'}" }
    RUBY
  end

  if bad 
    fragment << <<-RUBY
      bad.each  {|str| refute rx =~ str, "Unexpected match: #{'#{str.inspect}'}" }
    RUBY
  end
  fragment
end

num = 0

@oneliners.each {|x| x.program = "match #{x.program} end" }

programs = @oneliners + @programs

programs.each do |x|
  num += 1
  desc, code, regex, good, bad, examples = 
    x.description, x.program, x.regex, x.good, x.bad, x.examples
  assign_code = 
    if code.split("\n").size == 1
      "code = %q<#{code.chomp}>"
    else
      "code = <<-'END'\n    #{code.gsub("\\n", "\\n    ")}\n  END"
    end
  slug = desc.downcase.gsub(" ", "_").gsub("(", "").gsub(")", "").gsub("-", "_").gsub(",", "_").gsub("/", "_")
  number = '%03d' % num
  piece1 = <<-RUBY
    def test_#{number}_#{slug}
      #{assign_code}
      parser = Regexador::Parser.new 
      pattern = parser.pattern

      assert parser.program.parse(code)

      prog   = Regexador.new(code)
  
      good = #{good.inspect}
      bad  = #{bad.inspect}
      regex = #{regex.inspect}
  
      rx = prog.regexp
      assert rx.class == Regexp, "Not a regex! #{'#{rx.inspect}'}"
      assert rx == regex, "Expected: #{regex.inspect}\\nActual:   #{'#{rx.inspect}'}"

  RUBY

  piece2 = sanity_check(good, bad)
  piece3 = result_check(good, bad)

  piece4 = ""
  piece5 = "    end\n\n"

  pieces = piece1 + piece2 + piece3 + piece4 + piece5
  text << pieces
end

text << "\nend"

puts text

