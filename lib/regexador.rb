class Regexador 
  # Only a skeleton...
end

require_relative './regexador_parser'
require_relative './regexador_xform'

require 'parslet/convenience'

class Regexador
  def initialize(str, debug=false)
    @code = str
    if debug
      puts
      puts "---- Code: ------"
      puts str
      puts "-----------------"
    end

    @parser = Parser.new
    meth = debug ? :parse_with_debug : :parse
    @tree = @parser.send(meth, str)

    xform = Transform.new
    if debug
      puts "\n\nParser gives:"
      pp @tree
    end

    @regex_tree = xform.apply(@tree)
    @regex_str  = @regex_tree.to_s
    if debug
      puts "\n\nTransform gives:"
      pp @regex_tree
    end

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

  def =~(other)
    other = stringify(other)
    raise ArgumentError unless String === other
    match(other)
  end

  private
 
  def stringify(obj)
    return obj if String === obj
    return obj.to_str if obj.respond_to?(:to_str)
    return obj
  end
end
