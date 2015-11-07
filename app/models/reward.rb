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

class Reward < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :campaign_member

  attr_accessor :no_expiration
  
  def no_expiration
    ((expire_at - created_at) / 1.year) > 80 ? true : false
  end

  def can_expire?
    !no_expiration
  end

end
