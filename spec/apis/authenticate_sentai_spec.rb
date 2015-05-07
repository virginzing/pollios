require 'rails_helper'

describe "POST /authen/sentai", type: :api do

  before do
    generate_certification
  end
  
  it "authenticate with authen and right password" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:dummy).merge(password: "Nutty509"), format: :json

    expect(ApiToken.count).to eq(1)

    expect(ApiToken.first.app_id).to eq("com.pollios.polliosapp")

    expect(Apn::Device.count).to eq(0)

    expect(last_response.status).to eq(201)

    expect(json["response_status"]).to eq("OK")
  end

  it "authenticate with authen and wrong password" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:dummy).merge(password: "123456"), format: :json

    expect(last_response.status).to eq(401)

    expect(json["response_status"]).to eq("ERROR")

    expect(json["response_message"]).to eq(ExceptionHandler::Message::Auth::LOGIN_FAIL)
  end

  it "authen with device_token" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:dummy).merge(password: "Nutty509", device_token: "12345678 c0c342f0 3f2b6526 46fcf7b9 386c307d 2ac40035 25c1a045 74eda000"), format: :json
  
    expect(last_response.status).to eq(201)

    expect(Apn::Device.count).to eq(1)

    expect(ApiToken.count).to eq(1)

    expect(ApiToken.first.app_id).to eq("com.pollios.polliosapp")

    expect(last_response.status).to eq(201)

    expect(json["response_status"]).to eq("OK")
  end

end