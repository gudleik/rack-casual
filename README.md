Rack::Casual
============

A simple Rack middleware that does authentication using CAS or a token.
It kicks in whenever a 401 response is returned from the server.

Tested with
===========

* Ruby 1.8.7 / 1.9.2
* CAS 2.0 using rubycas-server
* Rails 3 and ActiveRecord 3
* Sinatra 1.0

Although ActiveRecord is not required, it uses ActiveRecord-ish methods to find and create users.
See examples/sinatra_app.rb for an example of which required methods the user model must support.

Installation
============

### Sinatra

    $ gem install 'rack-casual'
  
See examples/sinatra_app.rb for a sample Sinatra app.

### Rails 3

Add this to your Gemfile:

    $ gem 'rack-casual'
  
Run bundle install, and add a configuration file:

    $ rails generate rack_casual
  
This creates a config/initializers/rack-casual.rb file. 
Make sure *cas_url* points to your CAS server.
If your user model is called something other than "User", you can change this here.

Next you must configure your application to use the plugin. 
For Rails3, you can add this to your config/application.rb:

  config.middleware.use "Rack::Casual::Authentication"

Finally, to authenticate your users, add a before_filter to your controller:

    class ApplicationController < ActionController::Base
      before_filter :authenticate!
    end

If you want to have a named route to the CAS servers logout url, you can do this:

    # config/routes.rb
    match '/logout' => redirect(Rack::Casual::Client.logout_url), :as => :logout

If you pass a :url then the CAS server should display a message telling the user to follow 
the given link.
  
    # config/routes.rb
    match '/logout' => redirect(Rack::Casual::Client.logout_url(:url => "http://foo.example.org/logged_out")), :as => :logout


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

From your client you can now authenticate using a token: http://your-app.com/my-protected-webservice?auth_token=secret
  
If there are no users with that token, the client just receives the 401 error. 
It does not fallback to CAS or create a user automatically (doh).


Authorization
=============

Rack::Casual calls active? on your user model if that method exists to determine whether the user can log in or not.
So just add this to control whether authenticated users can log in or not.
  
    # app/models/user.rb
    class User < ActiveRecord::Base
      def active?
        # i'm sure you can figure something out...
      end
    end
  

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
These variables will be updated if they are present in your User model:

* last_login_at (datetime)
* last_login_ip (string)
* login_count   (integer)

Skipping URLs
=============

I couldn't find an easy way to disable a Rack Middleware in Rails, so I added a configure option to Rack::Casual called *ignore_url*.
Rack::Casual will not be called when the request.path matches the pattern in config.ignore_url.

Useful if you want a basic http authentication for /admin with a predefined set of users that is not part of your CAS infrastructure. 
Just set config.ignore_url = '^/admin' and Rack::Casual won't do anything when accessing URLs that matches /admin

Known issues
============

If Rack::Casual fails to create the user you'll end up in a redirect loop.

TODO
====

More tests dammit.

Copyright (c) 2010 Gudleik Rasch <gudleik@gmail.com>, released under the MIT license
