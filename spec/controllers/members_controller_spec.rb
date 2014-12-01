require 'rails_helper'

RSpec.describe MembersController, :type => :controller do
  describe "GET /list_members" do
    let!(:one) { create(:one) }
    let!(:two) { create(:two) }
    let(:body) { parse_json }

    before do
      get :list_members, format: :json
    end


    it "should have two members" do
      expect(response.status).to eq(200)
      expect(body.size).to eq(2)
    end

    it "should have nuttapon@code-app.com" do
      expect(response.status).to eq(200)
      list_members = body.collect{|e| e["email"] }
      expect(list_members.first).to eq("nuttapon@code-app.com")
    end

  end

  def parse_json
    body = JSON.parse(response.body)
  end
end
