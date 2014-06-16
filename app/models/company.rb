class Company < ActiveRecord::Base

  has_many :invite_codes, dependent: :destroy

  attr_accessor :amount_code, :used

  def generate_code_of_company(amount_code)
    InviteCode.create_invite_code(nil, amount_code.to_i, self.id)  
  end

end
