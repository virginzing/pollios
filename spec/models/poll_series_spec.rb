require 'rails_helper'

RSpec.describe PollSeries, :type => :model do
  it { should have_many(:save_poll_laters) }
end
