class AddNewPublicIdToMember < ActiveRecord::Migration
  def change
    add_column :members, :public_id, :string
  end
end
