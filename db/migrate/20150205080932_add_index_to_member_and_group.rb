class AddIndexToMemberAndGroup < ActiveRecord::Migration
  def change
    add_index :members, :fullname
    add_index :members, :public_id

    add_index :groups, :name
  end
end
