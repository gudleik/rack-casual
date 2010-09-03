# RackCasual
# encoding: utf-8

module Rack
  
  module Casual

    autoload :Authentication, 'rack/casual/authentication'
    autoload :Client,         'rack/casual/client'
    autoload :UserFactory,    'rack/casual/user_factory'
    
    if defined?(ActionController)
      autoload :Controller,     'rack/casual/controller'
    end
    
    # Default options
    defaults = {
      :cas_url          => nil,                 # CAS URL
      :session_key      => "user",              # Name of session key to store the user-id in
      :ticket_param     => "ticket",            # Name of parameter for the CAS ticket
      :create_user      => true,                # Automatic user creation
      :user_class       => "User",              # Name of user model
      :username         => "username",          # Name of username attribute in User model
      :auth_token       => "auth_token",        # Name of authentication token attribute in User model
      :tracking_enabled => true,                # Enable tracking on user
    }

    # Create attribute accessors for each key/value pair in options.
    defaults.each do |key, value|
      # value = value.is_a?(String) ? "'#{value}'" : %Q{"#{value}"}
      class_eval <<-EOS
        @@#{key} = nil unless defined? @@#{key}
        
        def self.#{key}
          @@#{key}
        end

        def self.#{key}=(value)
          @@#{key} = value
        end
      EOS
      
      # set the default value
      self.send("#{key}=", value)
    end

    # Setup Rack::Casual. Run rails generate rack_casual to create
    # a fresh initializer with all configuration values.
    def self.setup
      yield self
    end

  end

end

if defined?(ActionController::Base)
  class ActionController::Base
    include ::Rack::Casual::Controller
    
    # before_filter :authenticate!
    
    helper_method :logged_in?, :current_user
  end
end