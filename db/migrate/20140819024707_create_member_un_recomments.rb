class CreateMemberUnRecomments < ActiveRecord::Migration
  def change
    create_table :member_un_recomments do |t|
      t.references :member, index: true
      t.integer :unrecomment_id

      t.timestamps
    end
  end
end
