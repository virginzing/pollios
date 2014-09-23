class AddUpdatePersonalToMember < ActiveRecord::Migration
  def change
    add_column :members, :update_personal, :boolean,  default: false
  end
end
