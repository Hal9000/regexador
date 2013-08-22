require 'regexador'

program = <<-EOS
  dot = "."
  num = "25" D5 | `2 D4 D | maybe D1 0,2*D
  match WB num dot num dot num dot num WB end
EOS

pattern = Regexador.new(program)

puts "Give me an IP address"
str = gets.chomp

if pattern.match?(str)   # Simple true or false
  puts "Valid"
else
  puts "Invalid"
end

rx = pattern.to_regex    # Can also retrieve the actual regex
p rx
