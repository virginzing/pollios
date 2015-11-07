# == Schema Information
#
# Table name: rewards
#
#  id                 :integer          not null, primary key
#  campaign_id        :integer
#  title              :string(255)
#  detail             :text
#  created_at         :datetime
#  updated_at         :datetime
#  reward_expire      :datetime
#  total              :integer
#  claimed            :integer
#  odds               :integer
#  expire_at          :datetime
#  redeem_instruction :text
#  self_redeem        :boolean
#  options            :hstore
#

require 'rails_helper'

RSpec.describe Reward, :type => :model do

end
