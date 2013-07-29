
abort "Require out of order" if ! defined? Regexador

class Regexador::Parser
  rule(:kANY)          { str("any") }
  rule(:kMANY)         { str("many") }
  rule(:kMAYBE)        { str("maybe") }
  rule(:kMATCH)        { str("match") }
  rule(:kEND)          { str("end") }

  rule(:keyword)       { kANY | kMANY | kMAYBE | kMATCH | kEND }
end
