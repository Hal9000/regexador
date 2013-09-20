require 'parslet'

abort "Require out of order" if ! defined? Regexador

class Regexador::Parser < Parslet::Parser
end

require_relative './chars'    # These three files 
require_relative './predefs'  #   reopen the class
require_relative './keywords' #     Regexador::Parser

class Regexador::Parser
  rule(:space)         { match[" \t"].repeat(1) }
  rule(:space?)        { space.maybe }
  rule(:white)         { (endofline | match("\s")).repeat(1) }
  rule(:white?)        { white.maybe }

  rule(:lower)         { match('[a-z]') }
  rule(:upper)         { match('[A-Z]') }

  rule(:comment)       { cHASH >> space >> (cNEWLINE.absent? >> any).repeat(0) }
  rule(:endofline)     { space? >> comment.maybe >> cNEWLINE }

  rule(:digit)         { match('[0-9]') }
  rule(:digits)        { digit.repeat(1) }
  rule(:hexdigit)      { digit | match("[abcdef]") }
  rule(:quoted)        { match('[^"]').repeat(0) }
  rule(:single_quoted) { match("[^']").repeat(0) }
  rule(:graph_char)    { match ("[[:graph:]]") }   # { match('[!-~]') }
  rule(:name)          { keyword.absent? >> lower >> (lower | cUNDERSCORE | digit).repeat(0) }

  rule(:variable)      { name.as(:var) }
  rule(:capture_var)   { (cAT >> name.as(:cvar)) }
  rule(:parameter)     { (cCOLON >> name.as(:param)) }

  rule(:posix_class)   { cPERCENT >> name.as(:pclass) }

  rule(:string)        { cQUOTE >> quoted.as(:string) >> cQUOTE }

  rule(:simple_class)  { cSQUOTE >> single_quoted.as(:char_class) >> cSQUOTE }
  rule(:negated_class) { cTILDE >> cSQUOTE >> single_quoted.as(:neg_class) >> cSQUOTE }
  rule(:char_class)    { simple_class | negated_class }

  rule(:number)        { digits }
  rule(:numeric)       { number | variable | parameter }

  rule(:codepoint)     { cAMPERSAND >> (hexdigit >> hexdigit >> hexdigit >> hexdigit).as(:unicode) }

  rule(:char)          { (cTICK >> graph_char.as(:char)) | codepoint }

  rule(:simple_range)  { char.as(:c1) >> cHYPHEN >> char.as(:c2) }
  rule(:negated_range) { char.as(:nr1) >> cTILDE  >> char.as(:nr2) }
  rule(:range)         { negated_range | simple_range }

  rule(:negated_char)  { cTILDE  >> char.as(:nchar) }   #    ~`x means /[^x]/

  rule(:capture)       { capture_var.as(:lhs) >> space? >> (cEQUAL >> space? >> pattern.as(:rhs)).maybe }

  rule(:simple_pattern) { predef | range | negated_char | posix_class | string | 
                        # X        `a-`c   ~`a            %name         "abc"    
                          char_class | char | parameter | variable | capture }
                        # 'abc'        `a     :param      xyz        @xyz = ...

  rule(:qualifier)     { (kANY | kMANY | kMAYBE).as(:qualifier) >> fancy_pattern.as(:match_item) }

  rule(:repeat1)       { numeric.as(:num1) }
  rule(:repeat2)       { repeat1 >> cCOMMA >> numeric.as(:num2) }
  rule(:repetition)    { (repeat2 | repeat1) >> space? >> cTIMES >> space? >> fancy_pattern.as(:match_item) }

  rule(:parenthesized) { cLPAREN >> space? >> pattern >> space? >> cRPAREN }

  rule(:fancy_pattern)    { space? >> (repetition | simple_pattern | qualifier | parenthesized) >> space? }
                       #               num          `~"'             keyword     (

  rule(:concat)        { (fancy_pattern >> (space? >> fancy_pattern).repeat(0)).as(:sequence) }
 
  rule(:pattern)       { (concat >> space? >> (cBAR >> space? >> concat).repeat(0)).as(:alternation) }

  rule(:rvalue)        { pattern | numeric }   # a string is-a pattern

  rule(:assignment)    { space? >> name.as(:var) >> space? >> cEQUAL >> space? >> rvalue.as(:rvalue) }

  rule(:definitions)   { (endofline | assignment >> endofline).repeat(0) }

  rule(:oneline_clause)   { space? >> kMATCH >> space? >> pattern >> kEND >> endofline.maybe }

  rule(:single_line)      { endofline | space? >> pattern >> endofline }

  rule(:multiline_clause) { space? >> kMATCH >> endofline >> single_line.repeat(1).as(:lines) >> space? >> kEND >> endofline.maybe }

  rule(:match_clause)  { multiline_clause | oneline_clause }

  rule(:program)       { definitions.as(:definitions) >> match_clause.as(:match) }

  root(:program)
end

