require 'spec_helper'

describe 'Address' do
  it "exists" do
    address = Address.new
    address.should be_an_instance_of(Address)
  end

  it "adds record" do
    previous_count   = Address.count
    address          = Address.new
    address.id       = 1
    address.postcode = "AB10 1AB"
    address.town     = "Aberdeen"
    save_result      = address.save

    save_result.should be_true
    Address.count.should == previous_count + 1
  end

  it "stores proper attributes" do
    address          = Address.new
    address.id       = 2 
    address.postcode = "AB10 1AB"
    address.town     = "Aberdeen"
    address.save

    address_test                  = Address.get(address.id)
    address_test.postcode.should == "AB10 1AB"
    address_test.town.should     == "Aberdeen"
  end

  it "requires postcode value" do
    address      = Address.new
    address.id   = 3
    address.town = "Aberdeen"
    save_result  = address.save

    save_result.should be_false
  end

  it "requires town value" do
    address          = Address.new
    address.id       = 4
    address.postcode = "AB10 1AB"
    save_result      = address.save

    save_result.should be_false
  end

  it "requires unique ID value" do
    address_1, address_2 = Address.new, Address.new
    [address_1, address_2].each do |address|
      address.id = 5
      address.postcode = "AB10 1AB"
      address.town = "Aberdeen"
    end
    address_1.save
    lambda { address_2.save }.should raise_error
  end

  it "rejects invalid postcode value" do
    address = Address.new
    address.id = 6
    address.town = "Aberdeen"
    address.postcode = "AB10 IAB" # Invalid postcode
    save_result = address.save

    save_result.should be_false
  end

end
