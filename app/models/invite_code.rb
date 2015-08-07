# == Schema Information
#
# Table name: invite_codes
#
#  id         :integer          not null, primary key
#  code       :string(255)
#  used       :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  company_id :integer
#  group_id   :integer
#

class InviteCode < ActiveRecord::Base
  has_one :member_invite_code,  dependent: :destroy

  belongs_to :company
  belongs_to :group

  attr_accessor :amount_code, :prefix_name, :list_email

  def self.generate_invite_code
    begin
      code = (@code_prefix + SecureRandom.hex(3)).upcase
    end while InviteCode.exists?(code: code)
    return code
  end

  def self.create_invite_code(name = nil, number = nil, company_id = nil, group_id)
    @code_prefix = name || 'CA'

    total_code = number || 10

    company_id = company_id || 0

    # puts "total_code = #{total_code}"

    total_code.times do 
      InviteCode.create!(code: generate_invite_code, company_id: company_id, group_id: group_id)
    end

  end

  def self.add_more_invite_code(number, company_id, group_id)
    list_invite_code = []
    total_code = number || 10
    company_id = company_id || 0

    company = Company.find_by(id: company_id)
    
    @code_prefix = company.short_name || 'CA'

    total_code.times do 
      list_invite_code << InviteCode.create!(code: generate_invite_code, company_id: company_id, group_id: group_id)
    end
    list_invite_code
  end

  def self.check_valid_invite_code(code)
    find_invite_code = find_by(code: code)
    if find_invite_code.present?
      if find_invite_code.used
        {
          status: false,
          message: 'This code had used already.',
          status_code: :unprocessable_entity
        }
      else
        {
          status: true,
          object: find_invite_code,
          message: 'Success',
          status_code: :created
        }
      end
    else
      {
        status: false,
        message: 'Invalid Code.',
        status_code: :unprocessable_entity
      }
    end
  end

end
