
abort "Require out of order" if ! defined? Regexador

class Regexador::Parser
  rule(:pD)            { str("D") }      # /\d/
  rule(:pD0)           { str("D0") }     # /0/
  rule(:pD1)           { str("D1") }     # /[0-1]/
  rule(:pD2)           { str("D2") }     # /[0-2]/
  rule(:pD3)           { str("D3") }     # /[0-3]/
  rule(:pD4)           { str("D4") }     # /[0-4]/
  rule(:pD5)           { str("D5") }     # /[0-5]/
  rule(:pD6)           { str("D6") }     # /[0-6]/
  rule(:pD7)           { str("D7") }     # /[0-7]/
  rule(:pD8)           { str("D8") }     # /[0-8]/
  rule(:pD9)           { str("D9") }     # /\d/
  rule(:pX)            { str("X") }      # /./
  rule(:pWB)           { str("WB").as(:wb) }     # /\b/
  rule(:pCR)           { str("CR") }     # /\r/
  rule(:pLF)           { str("LF") }     # /\n/
  rule(:pNL)           { str("NL") }     # /\n/
  rule(:pCRLF)         { str("CRLF") }   # /\r\n/
  rule(:pSPACE)        { str("SPACE") }  # 
  rule(:pSPACES)       { str("SPACES") } # 
  rule(:pBLANK)        { str("BLANK") }  # 
  rule(:pBLANKS)       { str("BLANKS") } # 
  rule(:pBOS)          { str("BOS").as(:bos) }    # /^/
  rule(:pEOS)          { str("EOS").as(:eos) }    # /$/

  rule(:predef)        { pD0 | pD1 | pD2 | pD3 | pD4 | pD5 | pD6 | pD7 | pD8 | pD9 | pD |
                         pX | pWB | pCRLF | pCR | pLF | pNL | pSPACES | pSPACE | 
                         pBLANKS | pBLANK | pBOS | pEOS }
end
