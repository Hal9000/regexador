$LOAD_PATH << "." << "./lib"

require 'regexador'

require "minitest/autorun"


class TestRegexador < Minitest::Test

  def test_001_special_chars
    parser = Regexador::Parser.new 
    assert parser.cSQUOTE.parse("'")
    assert parser.cHASH.parse('#')
    assert parser.cNEWLINE.parse("\n")
    assert parser.cEQUAL.parse('=')
  end

  def test_002_intl_chars
    parser = Regexador::Parser.new 
    assert parser.char.parse_with_debug("`æ")
    assert parser.char.parse("`ß")
    assert parser.char.parse("`ç")
    assert parser.char.parse("`ö")
    assert parser.char.parse("`ñ")
  end

  def test_003_codepoints
    parser = Regexador::Parser.new 
    assert parser.codepoint.parse_with_debug("&1234")
    assert parser.codepoint.parse('&beef')
  end

  def test_004_predef_tokens
    parser = Regexador::Parser.new 
    %w(BOS EOS START END).each do |token|
      assert parser.pattern.parse_with_debug(token)
    end
  end

  def test_005_assignment
    parser = Regexador::Parser.new 
    assert parser.assignment.parse("a = 5")
    assert parser.assignment.parse("a= 5")
    assert parser.assignment.parse("a =5")
    assert parser.assignment.parse("a=5")
    assert parser.assignment.parse("myvar = 'xyz'")
    assert parser.assignment.parse('var2 = "hello"')
    assert parser.assignment.parse('this_var = `x-`z')
    assert parser.assignment.parse('pat = maybe many `x-`z')
  end

  def test_006_keyword_as_var
    parser = Regexador::Parser.new 
    assert_raises { parser.assignment.parse("end = 'hello'") }
    parser = Regexador::Parser.new 
    assert parser.assignment.parse_with_debug("endx = 'hello'")
    assert parser.assignment.parse_with_debug("end5 = 'hello'")
    assert parser.assignment.parse_with_debug("end_ = 'hello'")
    assert parser.assignment.parse_with_debug("anyx = 'hello'")
  end

  def test_007_def_section
    parser = Regexador::Parser.new 
    defs1 = <<-EOS
      a = 5
      str = "hello"
    EOS
    assert parser.definitions.parse(defs1), "assertion 1"
    defs2 = <<-EOF
      a = 5
      pat = maybe many `a-`c
      # empty line follows:

      str = "hello"
      # another comment...
    EOF
    assert parser.definitions.parse(defs2), "assertion 2"
  end

  def test_008_capture_var
    parser = Regexador::Parser.new 
    str1 = "@myvar"
    assert parser.capture_var.parse(str1)
  end

  def test_009_captured_pattern
    parser = Regexador::Parser.new 
    prog = "@myvar = maybe 'abc'"
    assert parser.capture.parse(prog)
    assert parser.parse("match #{prog} end")
  end

  def test_010_back_ref
    parser = Regexador::Parser.new 
    prog = '@myvar'
    parser.capture.parse(prog)
    assert parser.parse("match #{prog} end")
  end

  def test_011_one_line_match_clause
    parser = Regexador::Parser.new 
    mc1 = "match `a~`x end"
    assert parser.match_clause.parse(mc1)
  end

  def test_012_multiline_match_clause
    parser = Regexador::Parser.new 
    mc2 = <<-EOF
      match 
        `< "tag" WB 
        any ~`>
        # blah blah blah
        "</" "tag" `> 
      end
    EOF
    assert parser.multiline_clause.parse(mc2)
  end

  def test_013_oneline_program
    parser = Regexador::Parser.new 
    prog = "match `a-`f end"
    assert parser.parse_with_debug(prog)
  end

  def test_014_multiline_program
    parser = Regexador::Parser.new 
    prog1 = <<-EOF
      dot = "."
      num = "25" D5 | `2 D4 D | maybe D1 1,2*D
      match WB num dot num dot num dot num WB end
    EOF
    assert parser.program.parse(prog1)

    prog2 = <<-EOF
      # Warning: This one likely has errors!
  
      visa     = `4 12*D maybe 3*D
      mc       = `5 D5 14*D
      amex     = `3 '47' 13*D
      diners   = `3 (`0 D5 | '68' D) 11*D
      discover = `6 ("011" | `5 2*D) 12*D
      jcb      = ("2131"|"1800"|"35" 3*D) 11*D
  
      match visa | mc | amex | diners | discover | jcb end
    EOF
    assert parser.program.parse(prog2)
  end

  def test_015_neg_lookbehind
    parser = Regexador::Parser.new 
    prog = ' match without "USD" find 3*D end'

    assert parser.program.parse(prog)
    rx = Regexador.new(prog)
    assert rx.regexp == /(?<!USD)(\d){3}/
  end

  def test_010_neg_lookahead
  end

  def test_010_
  end

  def test_010_
  end

  def test_010_
  end

end
