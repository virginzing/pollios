require 'rails_helper'

describe "POST /authen/sentai", type: :api do

  before do
    generate_certification
    set_default_pollios_app
  end

  it "authenticate with authen and right password" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:dummy).merge(password: "1234567890"), format: :json

    expect(ApiToken.count).to eq(1)

    expect(ApiToken.first.app_id).to eq("com.pollios.polliosapp")

    expect(Apn::Device.count).to eq(0)
    expect(last_response.status).to eq(200)

    expect(json["response_status"]).to eq("OK")
  end

  it "authenticate with authen and wrong password" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:dummy).merge(password: "000000000"), format: :json

    expect(last_response.status).to eq(401)

    expect(json["response_status"]).to eq("ERROR")

    expect(json["response_message"]).to eq(ExceptionHandler::Message::Auth::LOGIN_FAIL)
  end

  it "authen with device_token" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:dummy).merge(password: "1234567890", device_token: "12345678 c0c342f0 3f2b6526 46fcf7b9 386c307d 2ac40035 25c1a045 74eda000"), format: :json

    expect(last_response.status).to eq(200)

    expect(Apn::Device.count).to eq(1)

    expect(ApiToken.count).to eq(1)

    expect(ApiToken.first.app_id).to eq("com.pollios.polliosapp")

    expect(last_response.status).to eq(200)

    expect(json["response_status"]).to eq("OK")
  end

end
