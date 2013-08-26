
abort "Require out of order" if ! defined? Regexador

class Regexador::Parser

  Predef2Regex = {
    pD:  "\\d", 
    pD0: "0", 
    pD1: "[01]", 
    pD2: "[0-2]", 
    pD3: "[0-3]", 
    pD4: "[0-4]", 
    pD5: "[0-5]", 
    pD6: "[0-6]", 
    pD7: "[0-7]", 
    pD8: "[0-8]", 
    pD9: "\\d", 
    pX:  ".", 

    pCR:     "\r", 
    pLF:     "\n", 
    pNL:     "\n", 
    pCRLF:   "\r\n", 

    pSPACE:  "\s",      # ?
    pSPACES: "\s+", 
    pBLANK:  "\s", 
    pBLANKS: "\s+", 

    pWB:    "\\b", 
    pBOS:   "^", 
    pEOS:   "$", 
    pSTART: "\A", 
    pEND:   "\Z"
  }

  # We need to reverse sort the keys so that longer keys are used before
  # shorter keys. (ie D0 vs. D)
  syms = Predef2Regex.keys.sort.reverse

  syms.each do |sym|
    # rule(:WB) { str('WB') }
    rule(sym) { str(sym.to_s[1..-1]) }  # strip leading "p"
  end

  # rule(:predef) { (pD | pD0 | ...).as(:predef) }
  rule(:predef) { 
    syms.map { |s| self.send(s) }.reduce(&:|).as(:predef) }
end
