require 'regexador'

# Without using parameters...

def analyze(word1, word2)
  pattern = Regexador.new("match \"#{word2}\" end")
  if pattern.match?(word1)
    puts "You can't spell '#{word1}' without '#{word2}'."
  else
    puts "'#{word1}' and '#{word2}'? No joke here. Move along."
  end
end

analyze("catastrophe", "cat")
analyze("hamburger", "beef")
analyze("senhoras", "horas")
