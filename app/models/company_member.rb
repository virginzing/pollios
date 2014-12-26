class CompanyMember < ActiveRecord::Base
  belongs_to :company
  belongs_to :member

  def self.add_member_to_company(member, company)
    CompanyMember.where(member: member, company: company).first_or_initialize do |cm|
      cm.member = member
      cm.company = company
      cm.save!
    end
  end
end

