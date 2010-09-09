# Configuration for Rack::Casual
# Commented values are default.

Rack::Casual.setup do |config|
  
  # Base URL to your CAS server -- required
  config.cas_url = 'http://localhost:8088'
  
  # If you want users to authenticate using an authentication token,
  # set the auth_token_key to the name of the attribute in your user model.
  # Users can now authenticate using http://your-app.com/?auth_token=a-very-secret-key
  # Setting this value to nil disables token authentication.
  # config.auth_token_key = 'auth_token'

  # Name of the session key used to store the user-id
  # Default is "user", so you get session[:user]
  # config.session_key = "user"

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
  
  # Tracking
  # If you have last_login_at and/or last_login_ip attributes on your User model,
  # Rack::Casual can update these when user logs in.
  # config.enable_tracking = true
  
  # Skipping paths
  # Rack::Casual ignores paths that matches this pattern.
  # If you want to have a separate http authentication for /admin, 
  # you can set ignore_url = '^/admin'
  # config.ignore_url = nil 
  
  ##
  ## CAS server settings
  ##

  # Name of the ticket parameter used by CAS.
  # config.ticket_param = 'ticket'
  
  # CAS service validation path
  # config.validate_url = '/serviceValidate'
  
  # CAS login path
  # config.login_url = '/login'
  
  # CAS logout path
  # config.logout_url = '/logout'
  
end
