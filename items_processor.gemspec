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

  gem.add_development_dependency "rspec", "~> 2.14.1"
end
