module CampaignsHelper

  extend Enumerize
  extend ActiveModel::Naming

  enumerize :type_campaign, :in => { random_immediately: 1, random_later: 2 }, predicates: true, default: :random_immediately, scope: true
end
