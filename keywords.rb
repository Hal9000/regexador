
abort "Require out of order" if ! defined? Regexador

class Regexador::Parser
  ANY    = "any"     # To internationalize the external DSL, only these strings
  MANY   = "many"    #   need be changed...
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
