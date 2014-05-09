module GroupMemberHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :notification, :in => { on: true, off: false }, default: :on, predicates: true

end
