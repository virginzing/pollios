require 'rails_helper'

RSpec.describe Choice, :type => :model do
  it { should validate_presence_of(:poll_id) }
  it { should validate_presence_of(:answer) }
end
