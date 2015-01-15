require 'rails_helper'

describe "POST /authen/facebook", type: :api do

  before do
    generate_certification
  end

  describe "no devise token" do
    before do
      @user_params = FactoryGirl.attributes_for(:facebook)
      post '/authen/facebook.json', @user_params, format: :json
    end

    it "authenticate with id and name" do
      expect(last_response.status).to eq(200)

      expect(json["response_status"]).to eq("OK")

      expect(json["member_detail"]["name"]).to eq(@user_params[:name])
    end

    # it "have one provider" do
    #   expect(Provider.count).to eq(1)
    #   expect(Provider.first.name).to eq("facebook")
    # end

    it "have not device " do
      expect(Apn::Device.all.count).to eq(0)
    end
  end


  it "authenticate with devise_token" do
    user_params = FactoryGirl.attributes_for(:facebook).merge(device_token: "11111111 11111111 11111111 11111111 11111111 11111111 11111111 11111111")

    post '/authen/facebook.json', user_params, format: :json

    expect(last_response.status).to eq(200)

    expect(Apn::Device.all.count).to eq(1)
  end

end