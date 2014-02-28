class AddProviderToMember < ActiveRecord::Migration
  def change
    add_column :members, :provider, :string
  end
end
