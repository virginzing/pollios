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

class BranchPoll < ActiveRecord::Base
  belongs_to :poll
  belongs_to :branch
end
