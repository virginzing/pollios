class AddMainGroupToGroupCompany < ActiveRecord::Migration
  def change
    add_column :group_companies, :main_group, :boolean, default: false
  end
end
