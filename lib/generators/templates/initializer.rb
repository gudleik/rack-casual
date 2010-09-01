# Configuration for Rack::Casual
# Commented values are default.

Rack::Casual.setup do |config|
  
  # Base URL to your CAS server -- required
  config.base_url = 'http://localhost:8088'
  
  # If you want users to authenticate using an authentication token,
  # set the auth_token_key to the name of the attribute in your user model.
  # Users can now authenticate using http://your-app.com/?auth_token=a-very-secret-key
  # Setting this value to nil disables token authentication.
  # config.auth_token_key = 'auth_token'

  # Name of the session key used to store the user-id
  # Default is "user", so you get session[:user]
  # config.session_key_user = "user"

  # Rack::Casual can create the user automatically on successful login
  # Set this to false to disable this feature.
  # If you want to include extra attributes provided by your CAS server,
  # you must add a cas_extra_attributes=(attributes) method in your User model.
  # See the README for an example.
  # config.create_user = true
  
  # If you have enabled create_user, here you can specify the name of your
  # user class. Defaults to 'User'.
  # config.user_class = "User"
  
  # This is the username attribute used by your User model.
  # config.username = "username"
  
  # Finding the user
  # You can set a custom scope that Rack::Casual should use when finding the user.
  # If you have a active scope, you can set this to :active.
  # config.authentication_scope = nil
  
  # Tracking
  # If you have last_login_at and/or last_login_ip attributes on your User model,
  # Rack::Casual can update these when user logs in.
  # config.enable_tracking = true

  # Name of the ticket parameter used by CAS.
  # config.ticket_param = 'ticket'
  
  # URL to the service validation on your CAS server.
  # nil = use defaults
  # config.validate_url = nil
  
  # CAS login url.
  # nil = use defaults
  # config.login_url = nil
  
  # CAS logout url.
  # nil = use defaults
  # config.logout_url = nil
  
end
