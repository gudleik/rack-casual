# encoding: utf-8
module Rack
  
  module Casual

    # How it works
    # 
    # 1. Request enters app
    # 2. Is params[:ticket] present with a valid CAS ticket
    # 3.    `- Validate ticket
    #          If valid find or create user
    #          User not ok? -- show bad info, don't redirect back to cas
    #          User ok? -- set user.id in session and continue
    # 5. Is response a 401?
    # 6.    `- Authenticate using auth_token if auth_token is present
    #       `- Or redirect to CAS
    # 7. Done
    # 
    class Authentication
      
      def initialize(app)
        @app = app
      end
  
      def call(env)
        @request  = Rack::Request.new(env)
        @env = env

        # Skip middleware if ignore_url is set and matches request.path
        if Rack::Casual.ignore_url && @request.path.match(Rack::Casual.ignore_url)
          @app.call(env)
        else
          unless process_request_from_cas
            @app.call(env)
          else
            handle_401(@app.call(env))
          end
        end
      end
  
      private
  
      # This handles requests from CAS
      # CAS requests must include a ticket in the params.
      # Only returns true if a CAS ticket was processed but returned no users
      def process_request_from_cas
        if ticket = read_ticket
          if user = UserFactory.authenticate_with_cas_ticket(ticket, service_url, @request.ip)
            set_session(user)
          else
            return false
          end
        end
        
        true
      end

      # This handles 401 responses by either authenticating using a token if present in params,
      # or redirects to CAS login
      def handle_401(response)
        return response unless response[0] == 401
    
        if Rack::Casual.auth_token && token = @request.params[Rack::Casual.auth_token]
          authenticate_with_token(token)
        else
          redirect_to_cas
        end
      end
      
      # Authenticate user by a token
      def authenticate_with_token(token)
        set_session UserFactory.authenticate_with_token(token, @request.ip)
        @app.call(@env)
      end

      # Stores user.id in the session key configured in Rack::Casual.session_key
      def set_session(user)
        @request.session[Rack::Casual.session_key] = user.id if user
      end
      
      # Redirects to CAS
      def redirect_to_cas
        [ 302, 
          { 
            "Location"      => Client.login_url(service_url),
            "Content-Type"  => "text/plain" 
          }, 
          "Redirecting to CAS for authentication" 
        ]
      end
    
      # Return the service url for this application (minus the ticket parameter)
      def service_url
        @request.url.sub(/[\?&]#{Rack::Casual.ticket_param}=[^\?&]+/, '')
      end
  
      # Read ticket from params and return a string if a CAS ticket is present.
      # Otherwise returns nil
      def read_ticket
        ticket = @request.params[Rack::Casual.ticket_param]
        ticket =~ /^(S|P)T-/ ? ticket : nil
      end

    end
  
  end
end