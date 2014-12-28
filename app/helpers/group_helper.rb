module GroupHelper
  extend Enumerize
  extend ActiveModel::Naming

  enumerize :authorize_invite, :in => { master: 0, everyone: 1 }, scope: :having_invite_type, default: :everyone
  enumerize :group_type, :in => { normal: 0, company: 1 },  default: :normal, scope: true,  predicates: { prefix: true }
end







# Group.all.each do |group|
#   if group.group_company.present?
#     group.update_attributes!(group_type: :company)
#     group.save!
#   else
#     group.update_attributes!(group_type: :normal)
#   end

# end