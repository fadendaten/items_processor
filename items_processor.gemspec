# -*- encoding: utf-8 -*-
require File.expand_path('../lib/items_processor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Rathesan Iyadurai", "Felix Langenegger", 
                       "Simon Kiener", "Christoph Wiedmer"]
  gem.email         = ["support@fadendaten.ch"]
  gem.description   = "This Library countains a basic Lineitems processing Interpreter."
  gem.summary       = "Lineitems processing library."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "items_processor"
  gem.require_paths = ["lib"]
  gem.version       = ItemsProcessor::VERSION
  
  gem.add_development_dependency "rspec", "~> 2.11.0"
end
