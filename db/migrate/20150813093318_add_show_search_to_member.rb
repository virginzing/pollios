class AddShowSearchToMember < ActiveRecord::Migration
  def change
    add_column :members, :show_search, :boolean,  default: true
  end
end
