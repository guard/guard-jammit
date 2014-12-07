# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'guard/jammit/version'

Gem::Specification.new do |s|
  s.name        = 'guard-jammit'
  s.version     = Guard::JammitVersion::VERSION
  s.authors     = ['Pelle Braendgaard', 'Michael Kessler']
  s.email       = ['pelle@stakeventures.com', 'michi@flinkfinger.com']
  s.homepage    = 'http://github.com/guard/guard-jammit'
  s.summary     = 'Guard plugin for Jammit'
  s.description = 'Watches your assets to automatically package them using Jammit.'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project = 'guard-jammit'

  s.add_dependency 'guard',      '>= 2.1.0'
  s.add_dependency 'guard-compat', '~> 1.0'
  s.add_dependency 'jammit'

  s.add_development_dependency 'bundler'

  s.files        = Dir.glob('{lib}/**/*') + %w(LICENSE README.md)
  s.require_path = 'lib'
end
