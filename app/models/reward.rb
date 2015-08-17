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

class Reward < ActiveRecord::Base
  belongs_to :campaign

  attr_accessor :unexpire
  
  def unexpired?
    ((reward_expire - created_at) / 1.year) > 80 ? true : false
  end

end
