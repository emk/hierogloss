# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hierogloss/version'

Gem::Specification.new do |spec|
  spec.name          = "hierogloss"
  spec.version       = Hierogloss::VERSION
  spec.authors       = ["Eric Kidd"]
  spec.email         = ["git@randomhacks.net"]
  spec.description   = %q{Extends the Markdown parser Kramdown to support hieroglyphs, inline multi-column glosses, and output to BBCode for use on forums.  Includes an executable for processing files and a webfont version of the Gardiner signs.}
  spec.summary       = %q{Markdown extensions for hieroglyphic glosses and BBCode}
  spec.homepage      = "https://github.com/emk/hierogloss"
  spec.license       = "Public domain + other open source licenses"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "kramdown", "~> 1.3"
  spec.add_development_dependency "prawn", "~> 0.14.0"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
