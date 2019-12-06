
abort "Require out of order" if ! defined? Regexador

class Regexador::Parser

  rule(:non_alphanum)  { lower.absent? >> upper.absent? >> cUNDERSCORE.absent? >> digit.absent? }

  rule(:kANY)          { str("any")      >> non_alphanum }
  rule(:kMANY)         { str("many")     >> non_alphanum }
  rule(:kMAYBE)        { str("maybe")    >> non_alphanum }
  rule(:kMATCH)        { str("match")    >> non_alphanum }
  rule(:kEND)          { str("end")      >> non_alphanum }
  rule(:kNOCASE)       { str("nocase")   >> non_alphanum }

  rule(:kWITH)         { str("with")     >> non_alphanum }
  rule(:kWITHOUT)      { str("without")  >> non_alphanum }
  rule(:kFIND)         { str("find")     >> non_alphanum }

  rule(:kWITHIN)       { str("within")   >> non_alphanum }
  rule(:kESCAPING)     { str("escaping") >> non_alphanum }

  rule(:keyword)       { kANY   | kMANY    | kMAYBE | kMATCH  | kEND | kNOCASE | 
                         kWITH  | kWITHOUT | kFIND  | kWITHIN | kESCAPING }
end
