require 'parslet'

abort "Require out of order" if ! defined? Regexador

class Regexador::Transform < Parslet::Transform
  rule(:char => simple(:char))    { char }
  rule(:c1 => simple(:c1), :c2 => simple(:c2)) { "[#{c1}-#{c2}]" }

  rule(:nr1 => simple(:nr1), :nr2 => simple(:nr2)) { "[^#{nr1}-#{nr2}]" }
  rule(:nchar => simple(:nchar))  { "[^#{nchar}]" }  # Don't forget escaping

  rule(:pclass => simple(:pclass)) { "[[:#{pclass}:]]" } # ??

  rule(:char_class => simple(:char_class)) { "[#{char_class}]" }
  rule(:neg_class => simple(:neg_class))   { "[^#{neg_class}]" }

  rule(:bos => simple(:pBOS)) { "^" }
  rule(:eos => simple(:pEOS)) { "$" }
  rule(:wb  => simple(:pWB))  { "\\b" }

  rule(:string => simple(:string))  { string }

  rule(:num1 => simple(:num1), :match_item => simple(:match_item)) { "(#{match_item}){#{num1}}" }
  
  rule(:num1 => simple(:num1), :num2 => simple(:num2), :match_item => simple(:match_item)) { "(#{match_item}){#{num1},#{num2}}" }
end

