class AddSettingToMember < ActiveRecord::Migration
  def change
    add_column :members, :setting, :hstore
    add_hstore_index :members, :setting
  end
end
