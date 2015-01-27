class AddReceiveNotifyToMembers < ActiveRecord::Migration
  def change
    add_column :members, :receive_notify, :boolean, default: true
  end
end
