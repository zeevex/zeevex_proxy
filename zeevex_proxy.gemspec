# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "zeevex_proxy/version"

Gem::Specification.new do |s|
  s.name        = "zeevex_proxy"
  s.version     = ZeevexProxy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Sanders"]
  s.email       = ["robert@zeevex.com"]
  s.homepage    = ""
  s.summary     = %q{Our homegrown version of a Proxy object}
  s.description = %q{This is a Proxy object; there are many others like it, but this one is ours.}

  s.rubyforge_project = "zeevex_proxy"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rspec', '~> 2.9.0'
  s.add_development_dependency 'rake'
end
