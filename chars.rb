abort "Require out of order" if ! defined? RegexadorParser

class RegexadorParser 
  rule(:cSQUOTE)     { str("'") }
  rule(:cQUOTE)      { str('"') }
  rule(:cTICK)       { str('`') }
  rule(:cBAR)        { str('|') }
  rule(:cPERCENT)    { str('%') }
  rule(:cCOMMA)      { str(',') }
  rule(:cHYPHEN)     { str('-') }
  rule(:cTILDE)      { str('~') }
  rule(:cUNDERSCORE) { str('_') }
  rule(:cEQUAL)      { str('=') }
  rule(:cHASH)       { str('#') }
  rule(:cTIMES)      { str('*') }
  rule(:cLPAREN)     { str('(') }
  rule(:cRPAREN)     { str(')') }
  rule(:cNEWLINE)    { str("\n") }
end
