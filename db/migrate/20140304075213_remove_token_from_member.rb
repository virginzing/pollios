class RemoveTokenFromMember < ActiveRecord::Migration
  def change
    remove_column :members, :token, :string
  end
end
