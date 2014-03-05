class AddUsernameIndexToMember < ActiveRecord::Migration
  def change
    add_index :members, :username
  end
end
