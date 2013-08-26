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
    # @tree   = @parser.parse_with_debug(str)
    @tree   = @parser.parse(str)

    xform = Transform.new
if $debug
puts "\n\nParser gives:"
pp @tree
end

    @regex_tree = xform.apply(@tree)
    @regex_str  = @regex_tree.to_s
if $debug
puts "\n\nTransform gives:"
pp @regex_tree
end

# p @regex_tree.to_s

    @regex = Regexp.compile(@regex_tree.to_s)
  end

  def to_regex
    @regex
  end

  def match(str, hash={})
    hash.each_pair do |var, val|
      @regex_str.gsub!(/\(#{var}\)\{0\}/, val)
    end
    @regex = Regexp.compile(@regex_str) unless hash.empty?
    result = @regex.match(str)
    return nil if result.nil?

    # Logic below may change...

    names = result.names
    obj = Object.new
    klass = obj.singleton_class
    names.each {|name| klass.class_eval { define_method(name) { result[name] } } }
    klass.class_eval { define_method(:[]) {|*args| args.map {|cvar| result[name] } } }
    obj
  end

  def match?(str, hash={})
    !!match(str, hash)  # Return Boolean
  end
end
