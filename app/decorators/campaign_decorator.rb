class CampaignDecorator < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all


  def show_expire
    object.expire.present? ? object.expire.strftime("%A, %d %B, %Y") : nil
  end

end
