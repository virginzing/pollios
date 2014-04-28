module MemberHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :gender, :in => { :undefined => 0, :male => 1, :female => 2 }, scope: :gender, predicates: true
  enumerize :member_type, :in => { citizen: 0, celebrity: 1, brand: 2 }, predicates: true, default: :citizen, scope: :member_type

end
