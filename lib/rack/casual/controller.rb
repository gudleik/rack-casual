module Rack
  
  module Casual
    
    module Controller

      def authenticate!
        authenticate_or_request_with_http_token unless logged_in?
      end

      def logged_in?
        !session[::Rack::Casual.session_key_user].nil?
      end

      def current_user
        @current_user ||= ::Rack::Casual::UserFactory.authentication_scope.find(session[:user])
      end

    end
  
  end
end