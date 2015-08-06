require 'rails_helper'

RSpec.describe Comment, :type => :model do

  describe "Attribute Validations" do
    it { should validate_presence_of(:message) }
  end

  describe "Association Validations" do
    it { should belong_to(:member) }
    it { should belong_to(:poll) }
  end

end