# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'net/https'
require 'yaml'

# Simple CAS client responsible for validating a ticket.
module Rack
  module Casual

    class Client
      attr_accessor :username, :extra_attributes

      # Creates a new object
      def initialize(service_url, ticket=nil)
        raise(ArgumentError, "Base URL must be configured") if Rack::Casual.cas_url.nil?

        @service_url  = service_url    
        @ticket       = ticket
        @result, @username, @extra_attributes = nil
      end
  
    
      # Helper that returns the CAS login url as string
      def self.login_url(service_url)
        cas_url(:login, :service => service_url).to_s
      end
      
      # Return url to CAS logout page
      def self.logout_url(options={})
        cas_url(:logout, options).to_s
      end
  
      # Return the URL to the CAS login page
      def login_url
        Client.cas_url(:login, :service => @service_url)
      end
  
      # URL to the CAS ticket validation service
      def validation_url
        Client.cas_url(:validate, :ticket => @ticket, :service => @service_url)
      end

      # Validate the ticket we got from CAS
      #
      # On ticket validation success:
      # <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
      #     <cas:authenticationSuccess>
      #         <cas:user>username</cas:user>
      #             <cas:proxyGrantingTicket>PGTIOU-84678-8a9d...
      #         </cas:proxyGrantingTicket>
      #     </cas:authenticationSuccess>
      # </cas:serviceResponse>
      # 
      # On ticket validation failure:
      # <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
      #     <cas:authenticationFailure code="INVALID_TICKET">
      #         Ticket ST-1856339-aA5Yuvrxzpv8Tau1cYQ7 not recognized
      #     </cas:authenticationFailure>
      # </cas:serviceResponse>
      # 
      #
      def validate_ticket
        url = validation_url
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = (url.scheme == "https") 
    
        body = http.get(url.request_uri).body
        puts "Result: #{body}"
        result = Nokogiri.parse(body)

        # set username and extra attributes
        find_username(result)
        find_attributes(result) if @username

        !@username.nil?
      end
  
      def find_username(xml)
        @username = xml.search("//cas:authenticationSuccess //cas:user").first.text rescue nil
      end
  
      def find_attributes(xml)
        @extra_attributes = {}
        xml.search("//cas:authenticationSuccess/*").each do |el|
          puts " * Attribute #{el.name} = #{el.content.to_s}"
          value = YAML::parse(el.content).value.first.value rescue nil
          @extra_attributes[el.name] = value
        end
      end

      #
      # Returns a CAS url
      # if action is :login or :validate, then the appropriate login and service-validation actions are used.
      # Otherwise the argument is used as the first action.
      #
      # Options is a hash that is appended to the url.
      #
      # Return value is a URI object.
      #
      # Examples:
      #
      #   cas_url :login                          # => http://localhost/login
      #   cas_url :validate, :ticket => "T123"    # => http://localhost/serviceValidate?ticket=T123
      #
      def self.cas_url(action=nil, options = {})
        url = Rack::Casual.cas_url.sub(/\/+$/, '')
    
        url << case action
        when :login    then "/login"
        when :logout   then "/logout"
        when :validate then "/serviceValidate"
        else
          action.to_s
        end
    
        options = options.reject { |key,value| value.nil? }
        if options.any?
          url += "?" + options.map{|key,value| "#{key}=#{value}" }.join("&")
        end

        URI.parse(url)
      end
      
    end

  end 
end