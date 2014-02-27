module RecurringsHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :status, :in => { :active => 1, :inactive => -1 }, scope: :having_status, predicates: true
end
