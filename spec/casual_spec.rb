require 'spec_helper'

describe "configuration" do
  
  let(:defaults) do
    {
      :cas_url          => nil,
      :session_key      => "user",              
      :ticket_param     => "ticket",            
      :create_user      => true,                
      :user_class       => "User",              
      :username         => "username",
      :auth_token       => "auth_token",        
      :tracking_enabled => true
    }
  end
  
  it "should have a reader and writer for each option" do
    defaults.each do |key, value|
      Rack::Casual.respond_to?(key).should be_true
      Rack::Casual.respond_to?("#{key}=").should be_true
    end
  end
  
  it "should have default values" do
    defaults.each do |key, value|
      Rack::Casual.send(key).should eq(value)
    end
  end

end