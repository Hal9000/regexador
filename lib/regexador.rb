class Regexador 
  # Only a skeleton...
end

require_relative './regexador_parser'
require_relative './regexador_xform'

require 'parslet/convenience'

class Regexador
  def initialize(str)
    @code = str
if $debug
puts
puts "---- Code: ------"
puts str
puts "-----------------"
end

    @parser = Parser.new
    @tree   = @parser.parse_with_debug(str)

    xform = Transform.new
if $debug
puts "\n\nParser gives:"
pp @tree

puts "\nAssign.bindings:"
pp Regexador::Transform::Assign.bindings
end

    @regex_tree = xform.apply(@tree)
if $debug
puts "\n\nTransform gives:"
p @regex_tree
end

    @regex = Regexp.compile(@regex_tree.to_s)
  end

  def to_regex
    @regex
  end

  def match(str)
    @regex.match(str)  # More to come...
  end
end
