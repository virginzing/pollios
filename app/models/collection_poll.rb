# == Schema Information
#
# Table name: collection_polls
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  company_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  sum_view_all :integer          default(0)
#  sum_vote_all :integer          default(0)
#  questions    :string(255)      default([]), is an Array
#

class CollectionPoll < ActiveRecord::Base
  belongs_to :company

  has_many :collection_poll_branches, dependent: :destroy
  has_many :branches, through: :collection_poll_branches, source: :branch

end
