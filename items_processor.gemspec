# -*- encoding: utf-8 -*-
require File.expand_path('../lib/items_processor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["fadendaten gmbh"]
  gem.email         = ["support@fadendaten.ch"]
  gem.description   = "This Library contains a basic Lineitems processing
                       interpreter used by all kinds of receipts."
  gem.summary       = "Lineitems processing library."
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "items_processor"
  gem.require_paths = ["lib"]
  gem.version       = ItemsProcessor::VERSION

  gem.add_development_dependency "rspec", "~> 3.1.0"
  gem.add_development_dependency "yard", "~> 0.8.7.6"
  # For markdown formatting of yard doc
  gem.add_development_dependency "redcarpet", "~> 3.2.0"
end
