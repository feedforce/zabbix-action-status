# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zabbix/action/status/version'

Gem::Specification.new do |spec|
  spec.name          = "zabbix-action-status"
  spec.version       = Zabbix::Action::Status::VERSION
  spec.authors       = ["Shota Miyamoto", "Takashi Masuda"]
  spec.email         = ["miyamoto@feedforce.jp", "masutaka@feedforce.jp"]

  spec.summary       = %q{Toggle zabbix actions.}
  spec.description   = %q{You can toggle zabbix actions}
  spec.homepage      = "https://github.com/feedforce/zabbix-action-status"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
