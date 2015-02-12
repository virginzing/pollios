require 'rails_helper'

describe "POST /authen/sentai", type: :api do

  before do
    generate_certification
  end
  
  it "authenticate with authen and right password" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:sentai).merge(password: "Nutty509"), format: :json

    expect(ApiToken.count).to eq(1)

    expect(ApiToken.first.app_id).to eq("123")

    expect(last_response.status).to eq(200)

    expect(json["response_status"]).to eq("OK")
  end

  it "authenticate with authen and wrong password" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:sentai).merge(password: "123456"), format: :json

    expect(last_response.status).to eq(403)

    expect(json["response_status"]).to eq("ERROR")

    expect(json["response_message"]).to eq("Invalid email or password")
  end

end