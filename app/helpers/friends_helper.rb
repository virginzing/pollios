module FriendsHelper
  extend Enumerize
  extend ActiveModel::Naming
  
  enumerize :status,  :in => { invite: 0, friend: 1, invitee: 2, nofriend: -1 }, predicates: true, scope: :having_status

end
