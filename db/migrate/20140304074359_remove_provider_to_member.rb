class RemoveProviderToMember < ActiveRecord::Migration
  def change
    remove_column :members, :provider, :string
    remove_column :members, :sentai_id, :string
  end
end
