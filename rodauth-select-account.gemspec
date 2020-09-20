# frozen_string_literal: true

require File.expand_path("lib/rodauth/select-account/version", __dir__)

Gem::Specification.new do |spec|
  spec.name          = "rodauth-select-account"
  spec.version       = Rodauth::SelectAccount::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Tiago Cardoso"]
  spec.email         = ["cardoso_tiago@hotmail.com"]

  spec.summary       = "Multiple authenticated accounts per session in rodauth."
  spec.description   = "Multiple authenticated accounts per session in rodauth."
  spec.homepage      = "https://gitlab.com/honeyryderchuck/rodauth-select-account"
  # spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://gitlab.com/honeyryderchuck/rodauth-select-account"
  spec.metadata["changelog_uri"] = "https://gitlab.com/honeyryderchuck/rodauth-select-account/-/blob/master/CHANGELOG.md"

  spec.files = Dir["LICENSE.txt", "README.md", "lib/**/*.rb", "templates/*", "CHANGELOG.md"]
  spec.extra_rdoc_files = Dir["LICENSE.txt", "README.md", "CHANGELOG.md"]

  spec.require_paths = ["lib"]
end
