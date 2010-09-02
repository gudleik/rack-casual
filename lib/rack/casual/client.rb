# encoding: utf-8

require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'net/https'

# This is a über simple CAS client responsible for validating a ticket.
class Rack::Casual::Client
  attr_accessor :username, :extra_attributes

  # Returns login url as string
  def self.login_url(service_url)
    new(service_url).login_url.to_s
  end
  
  # Creates a new object
  def initialize(service_url, ticket=nil)
    raise(ArgumentError, "Base URL must be configured") if Rack::Casual.cas_url.nil?

    @service_url  = service_url    
    @ticket       = ticket
    @result       = nil
  end
  
  # Return the URL to the CAS login page
  def login_url
    cas_url(:login)
  end
  
  # URL to the CAS ticket validation service
  def validation_url
    cas_url(:validate)
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
    
    result = Nokogiri.parse(http.get(url.request_uri).body)

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
      # puts " * Attribute #{el.name} = #{el.content}"
      @extra_attributes[el.name] = el.content
    end
  end

  # For testing purposes only
  #
  # Fetch login ticket from the CAS login page
  # def acquire_login_ticket(service_url=nil)
  #   Nokogiri.parse(open(login_url(service_url)).read).search('input[@name=lt]').first.attr('value') rescue nil
  # end
  # 
  # def authenticate(username, password, ticket, service_url=nil)
  #   ticket = acquire_login_ticket(service_url)
  #   url    = login_url(service_url)
  # 
  #   query  = url.query ? url.query : ""
  #   query  += "&" + build_query(:username => username, :password => password, :lt => ticket, :service => service_url)
  #   
  #   req    = Net::HTTP.new(url.host, url.port)
  #   res    = req.post url.path, query
  #   
  #   res.is_a?(Net::HTTPSuccess)
  # end

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
  def cas_url(action=nil, options = nil)
    url = Rack::Casual.cas_url.sub(/\/+$/, '')
    
    url << case action
    when :login    then "/login"
    when :validate then "/serviceValidate"
    else
      action.to_s
    end
    
    url += "?service=#{@service_url}"
    url += "&ticket=#{@ticket}" if @ticket
    URI.parse(url)
  end
      
end
