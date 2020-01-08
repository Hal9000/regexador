$:.push File.expand_path("../lib", __FILE__)

require 'date'
require 'find'

Gem::Specification.new do |s|
  s.name        = "regexador"
  s.version     = '0.4.6'  
  s.date        = Date.today.strftime("%Y-%m-%d")
  s.authors     = ["Hal Fulton", "Kaspar Schiess"]
  s.email       = ["rubyhacker@gmail.com"]
  s.homepage    = "http://github.com/hal9000/regexador"
  s.summary     = "A mini-language to make regular expressions more readable."
  s.description = <<-EOS
This is implemented as an "external DSL" in Ruby; that is (like SQL for example), 
a "program" in a Ruby string is passed into some kind of parser/interpreter method.
In this case, it is possible to use the result "as is" or to convert to an ordinary 
Ruby regular expression.

This project was originally implemented "for Ruby, using Ruby." Tentative efforts
are being made for ports to Elixir and Python.

Development on this project resumed in 2019 after being untouched since 2015. As such, 
it is not 100% mature. Syntax and semantics may change. Feel free to offer comments 
or suggestions.
EOS

  s.license       = "Ruby"

  s.files         = %w[README.md] + Find.find("lib").to_a
  s.test_files    = Find.find("test").to_a + 
                    Find.find("spec").to_a
  s.executables   = []
  s.require_paths = ["lib"]

  s.add_runtime_dependency "parslet"

  s.add_development_dependency "rspec", [">= 2.5.0"]  # phasing out
  s.add_development_dependency 'minitest'
end
