# encoding: utf-8
module Rack  
  module Casual
    
    class UserFactory

      # 
      # Authenticate user by CAS.
      #
      # If ticket is valid it will search for user with the given username.
      # If no user is found it will be automatically created if +Rack::Casual.create_user+ is set.
      #
      # Returns the user or nil if user not found
      #      
      def self.authenticate_with_cas_ticket(ticket, service_url, ip)
        user   = nil
        client = Client.new(service_url, ticket)
        
        if client.validate_ticket
          # find or create the user
          user = find(client.username)
          if user.nil? && Rack::Casual.create_user
            user = make(client.username)
          end

          return nil if user.nil? || user_not_active(user)

          # Set extra attributes if supported by user
          if user.respond_to?(:cas_extra_attributes=)
            user.cas_extra_attributes = client.extra_attributes 
          end

          update_tracking(user, ip)
        end

        user
      end

      #
      # Find user by authentication token.
      # If user exists and tracking is enabled, tracking info is updated.
      # Returns user or nil if user not found.
      #
      def self.authenticate_with_token(token, ip)
        user = resource.where(Rack::Casual.auth_token => token).first
        return nil if user_not_active(user)
        update_tracking(user, ip) if user
        user
      end
      
      def self.user_not_active(user)
        user.respond_to?(:active?) && user.send(:active?) == false
      end

      # Update tracking info (last logged in at / ip) if tracking_enabled is set.
      # Saves the user regardless of whether tracking was updated or not.
      def self.update_tracking(user, ip)
        if Rack::Casual.tracking_enabled
          user.last_login_at = Time.now   if user.respond_to?(:last_login_at)
          user.last_login_ip = ip         if user.respond_to?(:last_login_ip)
          user.login_count += 1           if user.respond_to?(:login_count)
        end
        user.save
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
        # Rack::Casual.user_class.constantize
        Kernel.const_get(Rack::Casual.user_class)
      end
    end
    
  end  
end