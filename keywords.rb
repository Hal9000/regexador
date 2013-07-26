
abort "Require out of order" if ! defined? RegexadorParser

class RegexadorParser
  rule(:kANY)          { str("any") }   # Worry about word boundaries later
  rule(:kMANY)         { str("many") }
  rule(:kMAYBE)        { str("maybe") }
  rule(:kMATCH)        { str("match") }
  rule(:kEND)          { str("end") }

  rule(:keyword)       { kANY | kMANY | kMAYBE | kMATCH | kEND }
end
