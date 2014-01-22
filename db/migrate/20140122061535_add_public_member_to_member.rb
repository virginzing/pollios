class AddPublicMemberToMember < ActiveRecord::Migration
  def change
    add_column :members, :public_member, :boolean, default: true
  end
end
