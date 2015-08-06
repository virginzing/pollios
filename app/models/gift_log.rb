# == Schema Information
#
# Table name: gift_logs
#
#  id          :integer          not null, primary key
#  admin_id    :integer
#  campaign_id :integer
#  message     :string(255)
#  list_member :text             default([]), is an Array
#  created_at  :datetime
#  updated_at  :datetime
#

class GiftLog < ActiveRecord::Base
  belongs_to :campaign
end
