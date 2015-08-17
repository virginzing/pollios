# == Schema Information
#
# Table name: redeemers
#
#  id         :integer          not null, primary key
#  company_id :integer
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Redeemer < ActiveRecord::Base
  belongs_to :company
  belongs_to :member
end
