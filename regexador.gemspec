# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "regexador"
  s.version     = '0.2.5'  
  s.authors     = ["Hal Fulton", "Kaspar Schiess"]
  s.email       = ["rubyhacker@gmail.com"]
  s.homepage    = "http://github.com/hal9000/regexador"
  s.summary     = "A mini-language to make regular expressions more readable."
  s.description = <<-EOS
This is implemented as an "external DSL" in Ruby; that is (like SQL for example), 
a "program" in a Ruby string is passed into some kind of parser/interpreter method.
In this case, it is possible to use the result "as is" or to convert to an ordinary 
Ruby regular expression.

Though this mini-language was conceived and implemented "for Ruby, using Ruby," 
in principle there is no reason it might not also be implemented in other languages
such as Python or Perl.

Development on this project began in mid-July 2013. As such, it is still an immature
project. Syntax and semantics may change. Feel free to offer comments or suggestions.
EOS

  s.license       = "The Ruby License"

  s.files         = %w[README.md
                       lib/chars.rb
                       lib/keywords.rb
                       lib/predefs.rb
                       lib/regexador.rb
                       lib/regexador_parser.rb
                       lib/regexador_xform.rb]
  s.test_files    = %w[spec/captures.yaml
                       spec/oneliners.yaml
                       spec/programs.yaml
                       spec/regexador_spec.rb]
  s.executables   = []
  s.require_paths = ["lib"]

  s.add_runtime_dependency "parslet"

  s.add_development_dependency "rspec", [">= 2.5.0"]
end
