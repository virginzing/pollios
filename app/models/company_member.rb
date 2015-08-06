# == Schema Information
#
# Table name: company_members
#
#  id         :integer          not null, primary key
#  company_id :integer
#  member_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

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

  def self.remove_member_to_company(member, company)
    find_company_member = CompanyMember.find_by(member: member, company: company)
    find_company_member.destroy if find_company_member.present?
  end
end

