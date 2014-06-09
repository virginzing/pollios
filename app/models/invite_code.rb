class InviteCode < ActiveRecord::Base
  has_one :member_invite_code

  def self.generate_invite_code
    begin
      code = @code_prefix + SecureRandom.hex(2)
    end while InviteCode.exists?(code: code)
    return code
  end

  def self.create_invite_code(name = nil, number = nil)
    @code_prefix = name || 'ca'

    total_code = number || 10

    total_code.times do 
      InviteCode.create!(code: generate_invite_code)
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