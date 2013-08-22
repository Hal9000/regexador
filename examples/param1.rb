require 'regexador'

# Doesn't work yet - parameters are not implemented yet.

def analyze(word1, word2)
  pattern = Regexador.new("match :short end")
  if pattern.match?(word1, short: word2)
    puts "You can't spell #{word1} without #{word2}."
  else
    puts "'#{word1}' and '#{word2}'? No joke here. Move along."
  end
end

analyze("hamburger", "beef")
analyze("catastrophe", "cat")
