module GroupHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :authorize_invite, :in => { master: 0, everyone: 1 }, predicates: true, scope: :having_invite_type, default: :everyone
end
