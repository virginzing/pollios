require 'rails_helper'

RSpec.describe AppReportsController, type: :controller do

  describe "GET #list_polls" do
    it "returns http success" do
      get :list_polls
      expect(response).to have_http_status(:success)
    end
  end

end
