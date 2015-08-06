require 'rails_helper'

RSpec.describe "Tag" do
  let!(:member) { create(:member) }

  # create_poll factory girl have 2 tags by default

  before do
    @poll = Poll.create_poll(FactoryGirl.attributes_for(:create_poll).merge(member_id: member.id), member)
  end

  describe "GET /hashtag_popular" do
    before do
      get "/hashtag_popular.json", { member_id: member.id }, { "Accept" => "application/json" }
    end

    it "success" do
      expect(json["response_status"]).to eq("OK")
    end

  end
end
