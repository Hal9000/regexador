
abort "Require out of order" if ! defined? Regexador

class Regexador::Parser
  ANY    = "any"
  MANY   = "many"
  MAYBE  = "maybe"
  MATCH  = "match"
  END_   = "end"     # END is a Ruby keyword...  

  rule(:kANY)          { str(ANY) }
  rule(:kMANY)         { str(MANY) }
  rule(:kMAYBE)        { str(MAYBE) }
  rule(:kMATCH)        { str(MATCH) }
  rule(:kEND)          { str(END_) }

  rule(:keyword)       { kANY | kMANY | kMAYBE | kMATCH | kEND }
end
