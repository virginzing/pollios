class CampaignDecorator < ApplicationDecorator
  include Draper::LazyHelpers

  delegate_all


  def show_expire
    object.expire.present? ? object.expire.strftime("%d/%m/%Y") : nil
  end

  def show_announce_on
    object.announce_on.present? ? object.expire.strftime("%d/%m/%Y") : nil
  end

end
