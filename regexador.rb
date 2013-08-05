class Regexador 
  # Only a skeleton...
end

require './regexador_parser'
require './regexador_xform'

class Regexador
  def initialize(str)
    @code = str
    @parser = Parser.new
    @tree   = @parser.parse(str)
    xform = Transform.new
puts "Parser gives:"
pp @tree
puts
    @regex_str = xform.apply(@tree)
puts "Transform gives:"
p @regex_str
puts
    @regex = Regexp.compile(@regex_str)
  end

  def to_regex
    @regex
  end

  def match(str)
    @regex.match(str)  # More to come...
  end
end
