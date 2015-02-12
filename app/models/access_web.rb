class AccessWeb < ActiveRecord::Base
  belongs_to :member
  belongs_to :accessable, polymorphic: true


  scope :with_company, -> (member_id) { where("access_webs.member_id = ? AND accessable_type = 'Company'", member_id) }


  def self.add_to_access_web(member, company)
    AccessWeb.where(member: member, accessable: company).first_or_initialize do |ac|
      ac.member = member
      ac.accessable = company
      ac.save
    end
  end

end
