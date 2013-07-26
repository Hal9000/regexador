
abort "Require out of order" if ! defined? RegexadorParser

class RegexadorParser
  rule(:pD)            { str("D") }      # { match("\d") }
  rule(:pD0)           { str("D0") }     # { str("0") }
  rule(:pD1)           { str("D1") }     # { match("[0-1]") }
  rule(:pD2)           { str("D2") }     # { match("[0-2]") }
  rule(:pD3)           { str("D3") }     # { match("[0-3]") }
  rule(:pD4)           { str("D4") }     # { match("[0-4]") }
  rule(:pD5)           { str("D5") }     # { match("[0-5]") }
  rule(:pD6)           { str("D6") }     # { match("[0-6]") }
  rule(:pD7)           { str("D7") }     # { match("[0-7]") }
  rule(:pD8)           { str("D8") }     # { match("[0-8]") }
  rule(:pD9)           { str("D9") }     # { match("\d") }
  rule(:pX)            { str("X") }      # { match(".") }
  rule(:pWB)           { str("WB") }     # { match("\b") }
  rule(:pCR)           { str("CR") }     # { match("\r") }
  rule(:pLF)           { str("LF") }     # { match("\n") }
  rule(:pNL)           { str("NL") }     # { match("\n") }
  rule(:pCRLF)         { str("CRLF") }   # { pCR >> pLF }
  rule(:pSPACE)        { str("SPACE") }  # { str(" ") }
  rule(:pSPACES)       { str("SPACES") } # { space }
  rule(:pBLANK)        { str("BLANK") }  # { str(" ") }
  rule(:pBLANKS)       { str("BLANKS") } # { space }
  rule(:pBOS)          { str("BOS") }    # { match("^") }
  rule(:pEOS)          { str("EOS") }    # { match("$") }

  rule(:predef)        { pD0 | pD1 | pD2 | pD3 | pD4 | pD5 | pD6 | pD7 | pD8 | pD9 | pD |
                         pX | pWB | pCRLF | pCR | pLF | pNL | pSPACES | pSPACE | 
                         pBLANKS | pBLANK | pBOS | pEOS }
end
