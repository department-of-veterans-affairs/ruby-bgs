Gem::Specification.new do |gem|
  gem.name          = "bgs"
  gem.version       = "0.2"
  gem.summary       = "Thin wrapper on top of savon to talk with BGS"
  gem.description   = "Thin wrapper on top of savon to talk with BGS"
  gem.license       = "CC0" # This work is a work of the US Federal Government,
  #               This work is Public Domain in the USA, and CC0 Internationally

  gem.authors       = "Caseflow"
  gem.email         = "vacaseflowops@va.gov"
  gem.homepage      = ""

  gem.add_runtime_dependency "nokogiri", ">= 1.11.0.rc4"
  gem.add_runtime_dependency "savon", "~> 2.12"
  gem.add_runtime_dependency "httpclient"
  gem.add_development_dependency "bundler-audit"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-nav"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rubocop", "<= 0.79"
  gem.add_development_dependency "byebug"

  gem.files         = Dir["lib/**/*.rb"]
  gem.require_paths = ["lib"]
end
