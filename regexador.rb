require 'parslet'
require 'parslet/convenience'

class RegexadorParser < Parslet::Parser
  # Only a skeleton...
end

require './chars'    # reopens the class
require './predefs'  # reopens the class

class RegexadorParser
  rule(:space)       { match('\s').repeat(1) }
  rule(:space?)      { space.maybe }

  rule(:lower)       { match('[a-z]') }
  rule(:upper)       { match('[A-Z]') }

  rule(:comment)     { cHASH >> match(".").repeat(0) }
  rule(:endofline)   { space? >> comment.maybe >> newline }

  rule(:digit)         { match('[0-9]') }
  rule(:digits)        { digit.repeat(1) }
  rule(:quoted)        { match('[^"]').repeat(0) }
  rule(:single_quoted) { match("[^']").repeat(0) }
  rule(:printable)     { match('[!-~]') }
  rule(:name)          { lower >> (lower | cUNDERSCORE | digit).repeat(0) }

  rule(:posix_class)   { cPERCENT >> name }

  rule(:string)        { cQUOTE >> quoted >> cQUOTE }
  rule(:simple_class)  { cSQUOTE >> single_quoted >> cSQUOTE }
  rule(:number)        { digits }
  rule(:char)          { cTICK >> printable }

  rule(:range)         { char >> cHYPHEN >> char }
  rule(:negated_range) { char >> cTILDE  >> char }
  rule(:negated_char)  { cTILDE  >> char }   #    ~`x means /[^x]/

  rule(:repeat1)       { number }
  rule(:repeat2)       { repeat1 >> cCOMMA >> number }

  rule(:kANY)          { str("any ") }   # Worry about word boundaries later
  rule(:kMANY)         { str("many ") }
  rule(:kMAYBE)        { str("maybe ") }
  rule(:kMATCH)        { str("match ") }
  rule(:kEND)          { str("end ") }

  rule(:keyword)       { kANY | kMANY | kMAYBE | kMATCH | kEND }

  rule(:predef)        { pD0 | pD1 | pD2 | pD3 | pD4 | pD5 | pD6 | pD7 | pD8 | pD9 | pD |
                         pX | pWB | pCRLF | pCR | pLF | pNL | pSPACES | pSPACE | 
                         pBLANKS | pBLANK | pBOS | pEOS }

  rule(:simple_match)  { predef | range | negated_range | negated_char | string | simple_class | char }
                       # X        `a-`c   `a~`c           ~`a            "abc"    'abc'          `a 

  rule(:qualifier)     { (kANY | kMANY | kMAYBE) >> match_item }
  rule(:repetition)    { (repeat2 | repeat1) >> cTIMES >> match_item }

  rule(:parenthesized) { cLPAREN >> space? >> pattern >> space? >> cRPAREN }

  rule(:match_item)    { space? >> (simple_match | qualifier | repetition | parenthesized) >> space? }
                       #            `~"'           kwd         num          (

  rule(:concat)        { (match_item >> (space? >> space? >> match_item).repeat(0))}
 
  rule(:pattern)       { (concat >> space? >> (space? >> cBAR >> space? >> concat).repeat(0)) >> space? }

  rule(:rvalue)        { number | pattern }   # a string is-a pattern

  rule(:assignment)    { space? >> name >> space? >> cEQUAL >> space? >> rvalue >> endofline }

  root(:assignment)
end


class Transform < Parslet::Transform
  
end

