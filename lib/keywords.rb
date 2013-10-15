
abort "Require out of order" if ! defined? Regexador

class Regexador::Parser

  rule(:kANY)          { str("any") }
  rule(:kMANY)         { str("many") }
  rule(:kMAYBE)        { str("maybe") }
  rule(:kMATCH)        { str("match") }
  rule(:kEND)          { str("end") }
  rule(:kNOCASE)       { str("nocase") }

  rule(:kWITH)         { str("with") }
  rule(:kWITHOUT)      { str("without") }
  rule(:kFIND)         { str("find") }

  rule(:kWITHIN)       { str("within") }
  rule(:kESCAPING)     { str("escaping") }

  rule(:keyword)       { kANY   | kMANY    | kMAYBE | kMATCH  | kEND | kNOCASE | 
                         kWITH  | kWITHOUT | kFIND  | kWITHIN | kESCAPING }
end
