class ChangeTypeColumnCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :select_service
    add_column :companies, :using_service, :string, array: true, default: '{}'
    add_index :companies, :using_service, using: 'gin'
  end
end
