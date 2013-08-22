require 'regexador'

prog = <<-EOS
  hr12 = (maybe `0) `1-`9 | `1 D2
  hr24 = (maybe `0) D | `1 D | `2 D3
  sep  = `: | `.
  min  = D5 D9
  sec  = D5 D9
  ampm = (maybe SPACE) ("am" | "pm")
  time24 = hr24 sep min maybe (sep sec) maybe ampm
  time12 = hr12 sep min maybe (sep sec)
  match BOS (time24 | time12) EOS end
EOS

pattern = Regexador.new(prog)
p pattern.to_regex

puts "What time is it?"
time = gets.chomp

if pattern.match? time
  puts "Valid"
else
  puts "Invalid!"
end

