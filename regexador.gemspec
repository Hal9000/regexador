# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "regexador"
  s.version     = '0.0.1'  
  s.authors     = ["Hal Fulton"]
  s.email       = ["rubyhacker@gmail.com"]
  s.homepage    = "http://github.com/hal9000/regexador"
  s.summary     = "A mini-language to make regular expressions more readable."
  s.description = s.summary

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

  s.add_development_dependency "bundler", ["~> 1.0.0"]
  s.add_development_dependency "rspec", [">= 2.5.0"]
end
