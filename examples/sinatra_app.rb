# encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'rack-casual'

##
## This is an example Sinatra app using Rack::Casual for authentication
##
## Start with ruby sinatra_app.rb 
## If you go to http://localhost:4567 you should be redirected to the CAS server.
## Or if you enter http://localhost:4567?auth_token=secret you're authenticated.
##

use Rack::Lint
use Rack::Casual::Authentication

Rack::Casual.setup do |config|
  config.cas_url     = "http://localhost:8080"
  config.auth_token  = "auth_token"
  config.session_key = "user"
  config.create_user = false
end

# User class with a few activerecord-ish methods to make Rack::Casual work properly.
# Didn't want to roll in a full activerecord orchestra for this example purpose.
class User
  attr_accessor :last_login_ip, :last_login_at, :login_count
  
  # This is used by Rack::Casual to locate the user.
  def self.where(conditions)
    if conditions["auth_token"] == "secret"       # find by auth_token
      [ User.new("foobar") ]
    elsif conditions["username"] == "foobar"      # find by username
      [ User.new("foobar") ]
    else
      []    # Must return an empty array to satisfy Rack::Casual (it uses .first)
    end
  end
  
  def id
    42
  end
  
  def active?
    false
  end
  
  def save
    # Just print out some info to see that these 
    puts "Last login IP: #{@last_login_ip}"
  end
  
  def initialize(username)
    @username = username
    @login_count = 0
  end
end

set :sessions, true

before do
  halt 401, 'Forbidden dammit' unless session["user"]
end

get '/' do
  %{Hello, your user-id is #{session["user"]}}
end