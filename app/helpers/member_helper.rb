module MemberHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :gender, :in => { :undefined => 0, :male => 1, :female => 2 }, scope: :having_gender, predicates: true
  enumerize :member_type, :in => { citizen: 0, celebrity: 1 }, predicates: true, default: :citizen, scope: :having_member_type

end
