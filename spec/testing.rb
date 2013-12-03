require_relative '../lib/regexador'
require 'pp'

require 'parslet/convenience'
require 'parslet/rig/rspec'

class Program
  attr_accessor :description, :program, :regex, :good, :bad, :examples

  def initialize(code)
    @code = code
    @parser = Regexador::Parser.new 
  end

  def parseable?
    result = @parser.parse(@code) rescue nil  # != nil
    !! result
  end

  def parse_pattern  # FIXME no longer used?
    tree = @parser.pattern.parse(@code)
    tree = tree[:alternation]         if tree.size == 1 && tree.keys.first == :alternation
    tree = tree[:sequence].first         if tree.size == 1 && tree.keys.first == :sequence
    tree
  end

  def parse
    tree = @parser.parse(@code)
  end

  def regexp
    Regexador.new(@code).to_regex
  end
end

