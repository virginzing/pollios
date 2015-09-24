class CreateMemberAgreeComments < ActiveRecord::Migration
  def change
    create_table :member_agree_comments do |t|
      t.references :member, index: true
      t.references :comment, index: true

      t.timestamps
    end
  end
end
