# == Schema Information
#
# Table name: branch_polls
#
#  id         :integer          not null, primary key
#  poll_id    :integer
#  branch_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe BranchPoll, :type => :model do

end
