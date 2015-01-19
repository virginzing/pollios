class AddWaitingToMember < ActiveRecord::Migration
  def change
    add_column :members, :waiting, :boolean,  default: false
  end
end
