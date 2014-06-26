class AddAnonymousToMember < ActiveRecord::Migration
  def change
    add_column :members, :anonymous, :boolean,  default: false
  end
end
