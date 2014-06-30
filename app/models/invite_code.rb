class InviteCode < ActiveRecord::Base
  has_one :member_invite_code,  dependent: :destroy
  belongs_to :company
  belongs_to :group


  def self.generate_invite_code
    begin
      code = (@code_prefix + SecureRandom.hex(2)).upcase
    end while InviteCode.exists?(code: code)
    return code
  end

  def self.create_invite_code(name = nil, number = nil, company_id = nil, group_id)
    @code_prefix = name || 'CA'

    total_code = number || 10

    company_id = company_id || 0

    puts "total_code = #{total_code}"

    total_code.times do 
      InviteCode.create!(code: generate_invite_code, company_id: company_id, group_id: group_id)
    end

  end

  def self.add_more_invite_code(number, company_id)
    total_code = number || 10
    company_id = company_id || 0

    company = Company.find_by(id: company_id)

    group_id = company.invite_codes.first.group_id

    @code_prefix = company.short_name || 'CA'

    total_code.times do 
      InviteCode.create!(code: generate_invite_code, company_id: company_id, group_id: group_id)
    end

  end

  def self.check_valid_invite_code(code)
    find_code = find_by(code: code)
    if find_code.present?
      if find_code.used
        {
          status: false,
          message: 'This code is used already.'
        }
      else
        {
          status: true,
          object: find_code,
          message: 'Success'
        }
      end
    else
      {
        status: false,
        message: 'Invalid code'
      }
    end
  end

end