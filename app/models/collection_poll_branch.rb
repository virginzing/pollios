# == Schema Information
#
# Table name: collection_poll_branches
#
#  id                 :integer          not null, primary key
#  branch_id          :integer
#  collection_poll_id :integer
#  poll_series_id     :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class CollectionPollBranch < ActiveRecord::Base
  belongs_to :branch
  belongs_to :collection_poll
end
