$LOAD_PATH << "." << "./lib"

require 'regexador'

require "minitest/autorun"


class TestRegexador < Minitest::Test

  def test_001_special_chars
    @parser = Regexador::Parser.new 
    assert @parser.cSQUOTE.parse("'")
    assert @parser.cHASH.parse('#')
    assert @parser.cNEWLINE.parse("\n")
    assert @parser.cEQUAL.parse('=')
  end

  def test_002_intl_chars
    @parser = Regexador::Parser.new 
    assert @parser.char.parse_with_debug("`æ")
    assert @parser.char.parse("`ß")
    assert @parser.char.parse("`ç")
    assert @parser.char.parse("`ö")
    assert @parser.char.parse("`ñ")
  end

  def test_003_codepoints
    @parser = Regexador::Parser.new 
    assert @parser.codepoint.parse_with_debug("&1234")
    assert @parser.codepoint.parse('&beef')
  end

  def test_004_predef_tokens
    @parser = Regexador::Parser.new 
    %w(BOS EOS START END).each do |token|
      assert @parser.pattern.parse_with_debug(token)
    end
  end
end
