require 'rails_helper'

RSpec.describe PollsController, :type => :controller do

  let!(:poll) { create(:poll) }

  describe "Poll" do

    it { should validate_presence_of(:title) }

  end
end

