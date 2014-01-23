class AddPublicIdToMember < ActiveRecord::Migration
  def change
    add_column :members, :public_id, :boolean, default: true
  end
end
