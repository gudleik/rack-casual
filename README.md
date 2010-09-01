Rack::Casual
============

A very simple Rack authentication plugin using CAS or a token.
It kicks in whenever a 401 response is returned from the server.

The plugin has only been tested using ActiveRecord and Rails 3.

Installation
============

Add this to your Gemfile:

  gem 'rack-casual'
  
Run bundle install, and add a configuration file:

  $ rails generate rack_casual
  
This creates a config/initializers/rack-casual.rb file. 
Make sure base_url points to your CAS server.
If your user model is called something other than "User", you can change this here.

Now, add a before_filter to your controller:

  class ApplicationController < ActionController::Base
    before_filter :authenticate!
  end


Usage
=====

Rack::Casual adds some helper methods to ActionController::Base

  * logged_in? 
  Returns true if session contains user-id
  
  * current_user
  Returns the currently logged in user.
  
  * authenticate!
  This is the method you want to use in a before_filter


Authentication token
====================

CAS is nice and all that, but it's not so nice for webservices. 
Therefore Rack::Casual can authenticate requests using a token.
Make sure your User model has a auth_token attribute. You can call it whatever you want, but it defaults to auth_token.

From your client you can now authenticate using this token:

  http://your-app.com/my-protected-webservice?auth_token=secret
  
If there are no users with that token, the client just receives the 401 error. 
It does not fallback to CAS or create a user automatically (doh).


Finding users
=============

If you want to control how Rack::Casual finds the user, you can set a scope to be used.
  # config/initializers/rack-casual.rb:
  config.authentication_scope = :active
  
  # app/models/user.rb
  class User < ActiveRecord::Base
    def self.active
      where(:active => true)
    end
  end
  
Then Rack::Casual will only search among users where active is true.
A side effect of this is that Rack::Casual will try to create a user that already exists.
However, this should not be a problem as long as your User model validates the uniqueness of the username.

The default scope to use is

Extra attributes
================

When creating users automatically, Rack::Casual can also add extra attributes if your CAS server provides this.
For this to work your User model must have a cas_extra_attributes= instance method.
Here's an example:

  class User < ActiveRecord::Base
    def cas_extra_attributes=(extra_attributes)
      extra_attributes.each do |name, value|
        case name.to_sym
          when :name   then self.name   = value
          when :email  then self.email  = value
          when :phone  then self.phone  = value
        end
      end
    end
  end
  

Tracking
========

If you have enabled tracking, Rack::Casual can update the logged in user with information about last login time and IP.
You must have a *last_login_at* attribute (datetime) and/or a *last_login_ip* attribute (string) in your User model for this to work.

TODO
====

Testing. How embarrasing. A gem without tests is like a forrest without trees.


Copyright (c) 2010 Gudleik Rasch <gudleik@gmail.com>, released under the MIT license
