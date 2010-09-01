module Rack
  
  module Casual
    
    class Authentication
      
      def initialize(app)
        @app = app
      end
  
      def call(env)
        @request  = Rack::Request.new(env)
        @response = @app.call(env)
        @env = env
    
        process_request_from_cas
        handle_401
      end
  
      private
  
      def process_request_from_cas
        if ticket = read_ticket
          if user = UserFactory.authenticate_with_cas_ticket(ticket, @request)
            @request.session[Rack::Casual.session_key_user] = user.id
          end
        else
          redirect_to_cas
        end
      end

      def handle_401
        return @response unless @response[0] == 401
    
        if Rack::Casual.auth_token_key && @request.params[Rack::Casual.auth_token_key]
          authenticate_with_token
        else
          redirect_to_cas
        end
      end
      
      def authenticate_with_token
        user = UserFactory.authenticate_with_token(@request)
        @request.session[Rack::Casual.session_key_user] = user.id if user
        @app.call(@env)
      end
  
      def redirect_to_cas
        url = Rack::Casual.cas_client.add_service_to_login_url(service_url)
        [ 302, 
          { 
            "Location"      => url,
            "Content-Type"  => "text/plain" 
          }, 
          "Redirecting to CAS for authentication" 
        ]
      end
  
      def service_url
        @request.url.sub(/[\?&]#{Rack::Casual.ticket_param}=[^\?&]+/, '')
      end
  
      # Read ticket from params and create a CASClient ticket
      def read_ticket
        ticket = @request.params[Rack::Casual.ticket_param]
        return nil unless ticket
          
        if ticket =~ /^PT-/
          ::CASClient::ProxyTicket.new(ticket, service_url, @request.params[:renew])
        else
          ::CASClient::ServiceTicket.new(ticket, service_url, @request.params[:renew])
        end
      end

    end
  
  end
end