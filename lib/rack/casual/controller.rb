module Rack
  
  module Casual
    
    module Controller

      def authenticate!
        authenticate_or_request_with_http_token unless logged_in?
      end

      def logged_in?
        !session[:user].nil?
      end

      def current_user
        @current_user ||= ::Rack::Casual::UserFactory.resource.find(session[:user])
      end

    end
  
  end
end