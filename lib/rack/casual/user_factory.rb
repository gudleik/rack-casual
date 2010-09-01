# encoding: utf-8
module Rack  
  module Casual
    
    class UserFactory

      def self.authenticate_with_cas_ticket(ticket, request)
        user = nil
        Rack::Casual.cas_client.validate_service_ticket(ticket) unless ticket.has_been_validated?

        if ticket.is_valid?

          # find user
          user = find(ticket.response.user)

          if user.nil? && Rack::Casual.create_user
            user = make(ticket.response.user)
          end

          return nil unless user

          if user.respond_to?(:cas_extra_attributes=)
            user.cas_extra_attributes = ticket.response.extra_attributes 
          end

          update_tracking(user, request)
        end

        user    
      end

      protected
      
      def self.authenticate_with_token(request)
        user = authentication_scope.where(Rack::Casual.auth_token_key => request.params[Rack::Casual.auth_token_key]).first
        update_tracking(user, request) if user
        user
      end

      # Update tracking info (last logged in at / ip) if tracking_enabled is set.
      # Saves the user regardless of whether tracking was updated or not.
      def self.update_tracking(user, request)
        if Rack::Casual.tracking_enabled
          user.last_login_at = Time.now   if user.respond_to?(:last_login_at)
          user.last_login_ip = request.ip if user.respond_to?(:last_login_ip)
          user.login_count += 1           if user.respond_to?(:login_count)
        end
        user.save
      end

      # Find user by username
      def self.find(username)
        authentication_scope.where(Rack::Casual.username => username).first
      end

      # Initializes a new user
      def self.make(username)
        resource.new(Rack::Casual.username => username)
      end

      # Returns the user class
      def self.resource
        Rack::Casual.user_class.constantize
      end
      
      # Returns the scope used to find users
      def self.authentication_scope
        if Rack::Casual.authentication_scope
          puts "Authentication scope is kinda broken and should be avoided"
          resource.send(Rack::Casual.authentication_scope)
        else
          resource.scoped
        end
      end
      
    end
    
  end  
end