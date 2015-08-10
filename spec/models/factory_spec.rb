require 'rails_helper'

RSpec.describe "Test FactoryGirl" do

  let!(:poll) { create(:poll_that_disable_comment) }

  it "have choices" do
    p poll.allow_comment
  end

end
