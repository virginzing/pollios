class AddFbIdToMembers < ActiveRecord::Migration
  def change
    add_column :members, :fb_id, :string
  end
end
