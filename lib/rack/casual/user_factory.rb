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
        user = resource.where(Rack::Casual.auth_token_key => request.params[Rack::Casual.auth_token_key]).first
        update_tracking(user, request) if user
        user
      end

      # Update tracking info (last logged in at / ip)
      def self.update_tracking(user, request)
        if Rack::Casual.tracking_enabled
          user.last_login_at = Time.now   if user.respond_to?(:last_login_at)
          user.last_login_ip = request.ip if user.respond_to?(:last_login_ip)
          user.save
        end
      end

      # Find user by username
      def self.find(username)
        resource.where(Rack::Casual.username => username).first
      end

      # Initializes a new user
      def self.make(username)
        resource.new(Rack::Casual.username => username)
      end

      # Returns the user class
      def self.resource
        Rack::Casual.user_class.constantize
      end

    end
    
  end  
end