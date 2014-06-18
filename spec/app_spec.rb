require 'spec_helper'

CONFIG = YAML.load_file('config/config.yaml')

describe "Sinatra App" do
  let(:api_key)       { CONFIG['api-key'] }
  let(:address_error) { { error: CONFIG['error-messages']['empty-params'] } }

  context "authenticated" do
    it "responds to GET request at /" do
      get '/', key: api_key
      last_response.should be_ok
    end
  
    it "responds to POST request at /update" do
      post '/update', id: 123, postcode: "AB10 1AB", town: "Aberdeen", key: api_key
      last_response.should be_ok
    end
  
    it "rejects empty POST at /update" do
      post '/update', key: api_key
      last_response.status.should == 404
    end
  
    it "responds to PUT request at /update/<addresskey>" do
      put '/update/12345', id: 12345, postcode: "AB10 1AB", town: "Aberdeen", key: api_key
      last_response.should be_ok
    end
  
    it "rejects empty PUT at /update/<addresskey>" do
      put '/update/12345', key: api_key
      last_response.status.should == 404
    end
  
    it "rejects GET request at /address/ without params" do
      get '/address', key: api_key
      last_response.status.should == 404
      last_response.body.should == address_error.to_json
    end
  
    it "response to GET request at /address/ with params" do
      get '/address?postcode=AB10+1AB', key: api_key
      last_response.should be_ok
    end
  
    it "rejects GET request at /postcode/ without params" do
      get '/postcode', key: api_key
      last_response.status.should == 404
      last_response.body.should == address_error.to_json
    end
  
    it "responds to GET request at /postcode/ with params" do
      get '/postcode?thoroughfare=ABC+Street&town=Aberdeen', key: api_key
      last_response.should be_ok
    end
  end

  context "unauthenticated" do
    it "rejects GET requests" do
      get '/'
      last_response.status.should == 401
    end

    it "rejects POST requests" do
      post '/update', id: 123, postcode: "AB10 1AB", town: "Aberdeen"
      last_response.status.should == 401
    end

    it "rejects PUT requests" do
      put '/update/12345/', id: 12345, postcode: "AB10 1AB", town: "Aberdeen"
      last_response.status.should == 401
    end
  end
end

