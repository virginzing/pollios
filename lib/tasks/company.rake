namespace :company do
  desc "create company member table"

  task create_member: :environment do
    Company.all.each do |company|
      company.groups.each do |group|
        group.get_member_active.each do |member|
          CompanyMember.add_member_to_company(member, company)
        end
      end
    end
  end

  task update_group_type: :environment do
    Group.update_all(group_type: 0)
    Group.all.each do |g|
      g.update(group_type: :company) if g.company?
    end
  end
  
end