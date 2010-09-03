require 'spec_helper'

describe Rack::Casual::Client do
  CAS_URL     = "http://localhost:8080"
  TICKET      = "ST-1283452541rB0287BFA91EA6854CF"
  SERVICE_URL = "http://localhost"
  
  before :all do
    Rack::Casual.setup do |config|
      config.cas_url = CAS_URL
    end
  end
  
  let(:client) { Rack::Casual::Client.new(SERVICE_URL, TICKET) }
  let(:invalid) { <<-EOT
    <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
        <cas:authenticationFailure code="INVALID_TICKET">
            Ticket ST-1856339-aA5Yuvrxzpv8Tau1cYQ7 not recognized
        </cas:authenticationFailure>
    </cas:serviceResponse>
  EOT
  }
  let(:valid) { <<-EOT
      <cas:serviceResponse xmlns:cas='http://www.yale.edu/tp/cas'>
        <cas:authenticationSuccess>
            <cas:user>foobar</cas:user>
                <cas:proxyGrantingTicket>PGTIOU-84678-8a9d...
            </cas:proxyGrantingTicket>
        </cas:authenticationSuccess>
    </cas:serviceResponse>
  EOT
  }
  
  describe "initialize" do
    it "should raise error on initialize when cas_url is nil" do
      Rack::Casual.stub(:cas_url).and_return(nil)
      lambda { Rack::Casual::Client.new(TICKET, SERVICE_URL) }.should raise_error
    end

    specify { client.username.should be_nil }
    specify { client.extra_attributes.should be_nil }

  end

  describe "login_url" do

    it "should return a URI object" do
      client.login_url.should be_a(URI)
    end
    
    it "should return login URL with the service callback url" do
      client.login_url.to_s.should eq("#{CAS_URL}/login?service=#{SERVICE_URL}")
    end
    
    it "should call cas_url with the service parameter" do
      Rack::Casual::Client.should_receive(:cas_url).with(:login, :service => SERVICE_URL)
      client.login_url
    end
    
    it "should have a login_url as a class method that returns a string" do
      Rack::Casual::Client.login_url(SERVICE_URL).should eq("#{CAS_URL}/login?service=#{SERVICE_URL}")
    end
  end
  
  describe "Client.logout_url" do
    it "should have a logout_url as class method that returns a string" do
      Rack::Casual::Client.logout_url.should eq("#{CAS_URL}/logout")
    end
    it "should accept a hash of options that should be included as query" do
      Rack::Casual::Client.logout_url(:url => "http://localhost/logged_out").should eq("#{CAS_URL}/logout?url=http://localhost/logged_out")
    end
  end
  describe "validation_url" do
    
    it "should return a URI object" do
      client.validation_url.should be_a(URI)      
    end
    
    it "should call cas_url" do
      Rack::Casual::Client.should_receive(:cas_url).with(:validate, :service => SERVICE_URL, :ticket => TICKET)
      client.validation_url
    end

  end
  
  describe "validate ticket" do
      
    describe "when invalid" do
      before(:each) do
        stub_request(:get, client.validation_url.to_s).to_return(:body => invalid)
      end
      
      it "it should return false" do
        client.validate_ticket.should be_false
      end
      
      it "then username should return nil" do
        client.validate_ticket
        client.username.should be_nil
      end
      
    end

    describe "when valid" do
      before(:each) do
        stub_request(:get, client.validation_url.to_s).to_return(:body => valid)
      end

      it "it should return true" do
        client.validate_ticket.should be_true
      end
    
      it "then username should be found" do
        client.validate_ticket
        client.username.should eq("foobar")
      end
      
    end
    
  end
  
  describe "extra_attributes" do
    it "should be nil after initialize" do
      client.extra_attributes.should be_nil
    end

    describe "on invalid response" do
      it "should never be set" do
        stub_request(:get, client.validation_url.to_s).to_return(:body => invalid)
        client.should_not_receive(:find_attributes)
        client.validate_ticket
        client.extra_attributes.should be_nil
      end
    end

    describe "on success" do
      before(:each) do
        stub_request(:get, client.validation_url.to_s).to_return(:body => valid)
      end
      
      it "should try to find extra attributes" do
        client.should_receive(:find_attributes)
        client.validate_ticket
        client.extra_attributes        
      end
      
      it "should be a hash" do
        client.validate_ticket
        client.extra_attributes.should be_a(Hash)
      end
    end
    
  end

  describe "cas_url" do

    it "should return CAS base URL without arguments" do
      Rack::Casual::Client.cas_url.to_s.should eq("#{Rack::Casual.cas_url}")
    end
    
    it "should return a URI object" do
      Rack::Casual::Client.cas_url.should be_a(URI)
    end
    
    it "should return login url when passing :login" do
      url = Rack::Casual::Client.cas_url(:login, :service => SERVICE_URL)
      url.should be_a(URI)
      url.to_s.should eq("#{CAS_URL}/login?service=#{SERVICE_URL}")
    end
    
    it "should return validation url when passing :validate" do
      url = Rack::Casual::Client.cas_url(:validate, :service => SERVICE_URL, :ticket => TICKET)
      url.should be_a(URI)
      url.to_s.should eq("#{CAS_URL}/serviceValidate?service=#{SERVICE_URL}&ticket=#{TICKET}")
    end
    
    it "should strip double slashes" do
      Rack::Casual.stub(:cas_url).and_return "http://cas.local//"
      client.login_url.to_s.should_not match %r{cas.local//login}
    end
    
    it "does something" do
      Rack::Casual::Client.cas_url(:logout, :url => "http://foobar.com/logout").to_s.should eq "#{CAS_URL}/logout?url=http://foobar.com/logout"
    end
  end
    
end