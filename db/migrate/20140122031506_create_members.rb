class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :sentai_id
      t.string :sentai_name
      t.string :username
      t.string :avatar
      t.string :token
      t.string :email
      t.integer :gender, default: 0

      t.timestamps
    end
  end
end
