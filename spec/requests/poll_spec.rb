require 'rails_helper'

RSpec.describe "Poll Feed API" do

  let(:ex_member) { create(:member, fullname: "Nutty", email: "nutty@gmail.com") }

  before do
    3.times do
      Poll.create_poll(FactoryGirl.attributes_for(:create_poll).merge(member_id: ex_member.id), ex_member)
    end

    get "/poll/#{ex_member.id}/overall_timeline", { api_version: 6 }, { "Accept" => "application/json" }
  end

  it "sends a list of polls feed" do
    expect(response).to be_success
    expect(json["response_status"]).to eq("OK")
  end

  it "returns three poll in poll feed " do
    expect(json["timeline_polls"].size).to eq(3)
  end

  it "returns 20 poll per request" do
    40.times do
      Poll.create_poll(FactoryGirl.attributes_for(:create_poll).merge(member_id: ex_member.id), ex_member)
    end

    get "/poll/#{ex_member.id}/overall_timeline", { api_version: 6 }, { "Accept" => "application/json" }

    expect(json["timeline_polls"].size).to eq(20)
  end

end