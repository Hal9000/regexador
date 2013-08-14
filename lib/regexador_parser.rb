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
  rule(:quoted)        { match('[^"]').repeat(0) }
  rule(:single_quoted) { match("[^']").repeat(0) }
  rule(:printable)     { match('[!-~]') }
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
  rule(:char)          { cTICK >> printable.as(:char) }

  rule(:simple_range)  { char.as(:c1) >> cHYPHEN >> char.as(:c2) }
  rule(:negated_range) { char.as(:nr1) >> cTILDE  >> char.as(:nr2) }
  rule(:range)         { negated_range | simple_range }

  rule(:negated_char)  { cTILDE  >> char.as(:nchar) }   #    ~`x means /[^x]/

  rule(:simple_match)  { predef | range | negated_char | posix_class | string | char_class | char | variable }
                       # X        `a-`c   ~`a            %             "abc"    'abc'        `a 

  rule(:qualifier)     { (kANY | kMANY | kMAYBE).as(:qualifier) >> match_item.as(:match_item) }

  rule(:repeat1)       { number.as(:num1) }
  rule(:repeat2)       { repeat1 >> cCOMMA >> number.as(:num2) }
  rule(:repetition)    { (repeat2 | repeat1) >> space? >> cTIMES >> space? >> match_item.as(:match_item) }

  rule(:parenthesized) { cLPAREN >> space? >> pattern >> space? >> cRPAREN }

  rule(:match_item)    { space? >> (simple_match | qualifier | repetition | parenthesized) >> space? }
                       #            `~"'           kwd         num          (

  rule(:concat)        { (match_item >> (space? >> match_item).repeat(0)).as(:sequence) }
 
  rule(:pattern)       { (concat >> space? >> (cBAR >> space? >> concat).repeat(0)).as(:alternation) }

  rule(:rvalue)        { pattern | number }   # a string is-a pattern

  rule(:assignment)    { space? >> name.as(:var) >> space? >> cEQUAL >> space? >> rvalue.as(:rvalue) }

  rule(:definitions)   { (endofline | assignment >> endofline).repeat(0) }

  rule(:capture)       { (capture_var >> space? >> cEQUAL >> space?).maybe >> pattern } # >> endofline }

  rule(:oneline_clause)   { space? >> kMATCH >> capture >> kEND >> endofline.maybe }

  rule(:single_line)      { endofline | capture >> endofline }

  rule(:multiline_clause) { space? >> kMATCH >> endofline >> single_line.repeat(1).as(:lines) >> space? >> kEND >> endofline.maybe }

  rule(:match_clause)  { oneline_clause | multiline_clause }

  rule(:program)       { definitions.as(:definitions) >> match_clause.as(:match) }

  root(:program)
end

