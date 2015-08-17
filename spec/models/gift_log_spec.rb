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

require 'rails_helper'

RSpec.describe GiftLog, :type => :model do

end
