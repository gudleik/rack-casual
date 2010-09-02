require 'rubygems'
require 'rspec'
require 'webmock/rspec'

# $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
# $LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rack-casual'

RSpec.configure do |config|
  config.include WebMock
end