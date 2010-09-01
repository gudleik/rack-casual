# RackCasual
# encoding: utf-8

module Rack
  
  module Casual

    autoload :Authentication, 'rack/casual/authentication'
    autoload :UserFactory,    'rack/casual/user_factory'
    autoload :Controller,     'rack/casual/controller'

    # Base URI to your CAS server
    mattr_accessor :base_url
    @@base_url = 'http://192.168.0.15:8088'

    # URI to CAS login
    # Default is base_url/login
    mattr_accessor :login_url
    @@login_url = nil

    # URI to CAS logout
    # Default is base_url/logout
    mattr_accessor :logout_url
    @@logout_url = nil

    # URI to service validation
    # Default is base_url/serviceValidate
    mattr_accessor :validate_url
    @@validate_url = nil

    # Name of authentication token to use in params
    # Set to nil to disable token authentication
    mattr_accessor :auth_token_key
    @@auth_token_key = "auth_token"

    # Name of the ticket parameter used by CAS
    mattr_accessor :ticket_param
    @@ticket_param = "ticket"

    # Name of key to store user id
    # Default is 'user' => session[:user]
    mattr_accessor :session_key_user
    @@session_key_user = "user"

    # Use this scope when finding users
    mattr_accessor :authentication_scope
    @@authentication_scope = nil

    # Set to true to auto-create users
    mattr_accessor :create_user
    @@create_user = true

    # Name of the User class
    mattr_accessor :user_class
    @@user_class = "User"

    # Username attribute on user
    mattr_accessor :username
    @@username = "username"

    # Update user with last_login_at and last_login_ip info
    mattr_accessor :tracking_enabled
    @@tracking_enabled = true

    # Default way to setup Devise. Run rails generate devise_install to create
    # a fresh initializer with all configuration values.
    def self.setup
      yield self
    end

    def self.cas_client
      @@cas_client ||= ::CASClient::Client.new(
          :cas_base_url => @@base_url,
          :login_url    => @@login_url,
          :logout_url   => @@logout_url,
          :validate_url => @@validate_url
        )
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