# == Schema Information
#
# Table name: rewards
#
#  id            :integer          not null, primary key
#  campaign_id   :integer
#  title         :string(255)
#  detail        :text
#  photo_reward  :string(255)
#  order_reward  :integer          default(0)
#  created_at    :datetime
#  updated_at    :datetime
#  reward_expire :datetime
#

require 'rails_helper'

RSpec.describe Reward, :type => :model do

end
