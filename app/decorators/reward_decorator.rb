class RewardDecorator < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all


  def show_reward_expire
    object.reward_expire.present? ? object.reward_expire.strftime("%d/%m/%Y") : nil
  end

end
