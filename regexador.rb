class Regexador 
  # Only a skeleton...
end

require './regexador_parser'
require './regexador_xform'

require 'parslet/convenience'

class Regexador
  def initialize(str)
    @code = str
puts
puts "---- Code: ------"
puts str
puts "-----------------"

    @parser = Parser.new
    @tree   = @parser.parse_with_debug(str)

#   Transform::Assign.bindings = {}
    xform = Transform.new
puts "\n\nParser gives:"
pp @tree

puts "\nAssign.bindings:"
pp Regexador::Transform::Assign.bindings

    @regex_tree = xform.apply(@tree)
puts "\n\nTransform gives:"
p @regex_tree

    @regex = Regexp.compile(@regex_tree.to_regex)
  end

  def to_regex
    @regex
  end

  def match(str)
    @regex.match(str)  # More to come...
  end
end
