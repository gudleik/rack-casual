# -*- encoding: utf-8 -*-
# lib = File.expand_path('../lib/', __FILE__)
# $:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "rack-casual"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Gudleik Rasch"]
  s.email       = ["gudleik@gmail.com"]
  s.homepage    = "http://github.com/gudleik/rack-casual"
  s.summary     = "CAS and token authentication using Rack"
  s.description = "Rack module for authentication using CAS and/or tokens"
 
  s.required_rubygems_version = ">= 1.3.7"
  # s.add_development_dependency "rspec"
  
  # s.add_dependency("rubycas-client")
  s.add_dependency("rubycas-client", ["~> 2.2.1"])
  s.add_dependency("activerecord", ["~> 3.0.0"])
  
  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE README.md)
  s.require_path = 'lib'
end