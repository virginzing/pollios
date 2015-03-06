require 'rails_helper'

RSpec.describe Comment, :type => :model do
  it { should validate_presence_of(:message) }

  it { should belong_to(:member) }
  it { should belong_to(:poll) }
end