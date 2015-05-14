module CampaignMembersHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :reward_status, :in => { waiting_announce: 0, receive: 1, not_receive: -1 }, predicates: true, scope: true

end