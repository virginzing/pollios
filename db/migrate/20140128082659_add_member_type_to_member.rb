class AddMemberTypeToMember < ActiveRecord::Migration
  def change
    remove_column :members, :public_id
    add_column :members, :member_type, :integer, default: 0
  end
end
