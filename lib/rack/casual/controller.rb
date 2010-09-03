# encoding: utf-8
module Rack
  
  module Casual

    # Mixin module for ActionController
    module Controller

      # Will send a 401 response to the user if user isn't logged in.
      def authenticate!
        authenticate_or_request_with_http_token unless logged_in?
      end

      # Returns true if user is logged in
      def logged_in?
        !session[Casual.session_key].nil?
      end

      # Returns the logged in user
      def current_user
        return @current_user if @current_user
        @current_user = UserFactory.resource.find(session[Casual.session_key])
        
        # If user is not active, unset session
        if UserFactory.user_not_active(@current_user)
          @current_user = nil 
          session[Casual.session_key] = nil
        end
        
        @current_user
      end

    end
  
  end
end