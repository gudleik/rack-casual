# -*- encoding: utf-8 -*-
# lib = File.expand_path('../lib/', __FILE__)
# $:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "rack-casual"
  s.version     = "0.1.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Gudleik Rasch"]
  s.email       = ["gudleik@gmail.com"]
  s.homepage    = "http://github.com/gudleik/rack-casual"
  s.summary     = "CAS and token authentication using Rack"
  s.description = "Rack middleware for authentication using CAS and/or tokens"
 
  s.required_rubygems_version = ">= 1.3.7"

  s.add_dependency("nokogiri", ["~> 1.4.3"])

  s.add_development_dependency "rspec", ["~> 2.0.0.beta.20"]
  s.add_development_dependency "webmock", ["~> 1.3"]
  
  s.files        = Dir.glob("{lib}/**/*") + %w(LICENSE README.md examples/sinatra_app.rb) 
  s.require_path = 'lib'
end