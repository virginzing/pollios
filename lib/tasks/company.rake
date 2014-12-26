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

end