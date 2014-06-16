class AddCompanyIdToInviteCode < ActiveRecord::Migration
  def change
    add_reference :invite_codes, :company, index: true
  end
end
