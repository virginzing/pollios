require 'rails_helper'

describe "POST /authen/facebook", type: :api do

  before :each do
    post '/authen/facebook.json', user_params, format: :json
  end

  it "authenticate with id and name" do
    user_params = FactoryGirl.attributes_for(:facebook)

    expect(last_response.status).to eq(200)

    expect(json["member_detail"]["name"]).to eq(user_params[:name])

    expect(Provider.count).to eq(1)

    expect(Provider.first.name).to eq("facebook")

    expect(Apn::Device.all.count).to eq(0)
  end

  it "authenticate with devise_token" do
    user_params = FactoryGirl.attributes_for(:facebook).merge(device_token: "11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111")
  end

end