class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.references :member, index: true
      t.string :email
      t.integer :invitee_id

      t.timestamps
    end
  end
end
