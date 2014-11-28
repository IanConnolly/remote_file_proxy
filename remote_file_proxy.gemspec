# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'remote_file_proxy/version'

Gem::Specification.new do |spec|
  spec.name          = "remote_file_proxy"
  spec.version       = RemoteFileProxy::VERSION
  spec.authors       = ["Ian Connolly"]
  spec.email         = ["ian@connolly.io"]
  spec.summary       = %q{Client Proxy for Dist Sys. Project}
  spec.description   = %q{Client Proxy for Dist Sys. Project}
  spec.homepage      = "http://github.com/IanConnolly/remote_file_proxy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
