require 'rails_helper'

describe "POST /authen/sentai", type: :api do

  before do
    generate_certification
  end
  
  it "authenticate with authen and right password" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:sentai).merge(password: "mefuwfhfu"), format: :json

    expect(last_response.status).to eq(200)

    expect(json["response_status"]).to eq("OK")
  end

  it "authenticate with authen and wrong password" do
    post '/authen/signin_sentai.json', FactoryGirl.attributes_for(:sentai).merge(email: "123456789@gmail.com"), format: :json

    expect(last_response.status).to eq(200)

    expect(json["response_status"]).to eq("ERROR")

    expect(json["response_message"]).to eq("Invalid password")
  end
end