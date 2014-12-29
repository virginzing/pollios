require 'rails_helper'

RSpec.describe FeedbackController, :type => :controller do

  describe "GET list_poll" do
    it "returns http success" do
      get :list_poll
      expect(response).to be_success
    end
  end

  describe "GET list_branch" do
    it "returns http success" do
      get :list_branch
      expect(response).to be_success
    end
  end

end
