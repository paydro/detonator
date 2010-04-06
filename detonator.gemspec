# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'detonator'

Gem::Specification.new do |s|
  s.name        = "detonator"
  s.version     = Detonator::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Peter Bui"]
  s.email       = ["peter@paydrotalks.com"]
  # s.homepage    = "http://"
  s.summary     = "MongoDB ORM built with ActiveModel"
  s.description = "Simple ORM built with MongoDB and ActiveModel. "

  s.required_rubygems_version = ">= 1.3.6"
  # s.rubyforge_project         = "bundler"

  s.add_development_dependency "activemodel"
  s.add_development_dependency "mongo"
  s.add_development_dependency "mongo_ext"

  s.files        = Dir.glob("lib/**/*") #+ %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  # s.executables  = ['']
  s.require_path = 'lib'
end

