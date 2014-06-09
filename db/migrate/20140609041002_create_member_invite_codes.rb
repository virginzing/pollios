class CreateMemberInviteCodes < ActiveRecord::Migration
  def change
    create_table :member_invite_codes do |t|
      t.references :member, index: true
      t.references :invite_code, index: true

      t.timestamps
    end
  end
end
