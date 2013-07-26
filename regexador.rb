require 'parslet'
require 'parslet/convenience'

class RegexadorParser < Parslet::Parser
  # Only a skeleton...
end

require './chars'    # These three files 
require './predefs'  #   reopen the class
require './keywords' #     RegexadorParser

class RegexadorParser
  rule(:space)       { match('\s').repeat(1) }
  rule(:space?)      { space.maybe }

  rule(:lower)       { match('[a-z]') }
  rule(:upper)       { match('[A-Z]') }

  rule(:comment)     { cHASH >> space >> match(".").repeat(0) }
  rule(:endofline)   { space? >> comment.maybe >> match("\n").maybe }

  rule(:digit)         { match('[0-9]') }
  rule(:digits)        { digit.repeat(1) }
  rule(:quoted)        { match('[^"]').repeat(0) }
  rule(:single_quoted) { match("[^']").repeat(0) }
  rule(:printable)     { match('[!-~]') }
  rule(:name)          { lower >> (lower | cUNDERSCORE | digit).repeat(0) }

  rule(:variable)      { name }
  rule(:capture_var)   { cAT >> name }
  rule(:parameter)     { cCOLON >> name }

  rule(:posix_class)   { cPERCENT >> name }

  rule(:string)        { cQUOTE >> quoted >> cQUOTE }

  rule(:simple_class)  { cSQUOTE >> single_quoted >> cSQUOTE }
  rule(:negated_class) { cTILDE >> simple_class }
  rule(:char_class)    { simple_class | negated_class }

  rule(:number)        { digits }
  rule(:char)          { cTICK >> printable }

  rule(:simple_range)  { char >> cHYPHEN >> char }
  rule(:negated_range) { char >> cTILDE  >> simple_range }
  rule(:range)         { negated_range | simple_range }

  rule(:negated_char)  { cTILDE  >> char }   #    ~`x means /[^x]/

  rule(:simple_match)  { predef | range | negated_char | string | char_class | char | variable }
                       # X        `a-`c   ~`a            "abc"    'abc'        `a 

  rule(:qualifier)     { (kANY | kMANY | kMAYBE) >> match_item }

  rule(:repeat1)       { number }
  rule(:repeat2)       { repeat1 >> cCOMMA >> number }
  rule(:repetition)    { (repeat2 | repeat1) >> space? >> cTIMES >> space? >> match_item }

  rule(:parenthesized) { cLPAREN >> space? >> pattern >> space? >> cRPAREN }

  rule(:match_item)    { space? >> (simple_match | qualifier | repetition | parenthesized) >> space? }
                       #            `~"'           kwd         num          (

  rule(:concat)        { (match_item >> (space? >> space? >> match_item).repeat(0))}
 
  rule(:pattern)       { (concat >> space? >> (space? >> cBAR >> space? >> concat).repeat(0)) >> space? }

  rule(:rvalue)        { number | pattern }   # a string is-a pattern

  rule(:assignment)    { space? >> name >> space? >> cEQUAL >> space? >> rvalue >> endofline }

  rule(:statement)     { assignment >> endofline }  # null statement is allowed
  rule(:definitions)   { (statement.repeat(0) >> endofline) }

  rule(:capture)       { (capture_var >> space? >> cEQUAL >> space?).maybe >> pattern >> endofline.maybe }

  rule(:match_clause)  { space? >> kMATCH >> capture.repeat(1) >> kEND >> endofline.maybe }

  rule(:program)       { definitions >> match_clause }   # EOF??

  root(:program)
end


class Transform < Parslet::Transform
  
end

