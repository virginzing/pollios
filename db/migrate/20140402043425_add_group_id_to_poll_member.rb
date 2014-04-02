class AddGroupIdToPollMember < ActiveRecord::Migration
  def change
    add_column :poll_members, :in_group, :boolean, default: false
  end
end
