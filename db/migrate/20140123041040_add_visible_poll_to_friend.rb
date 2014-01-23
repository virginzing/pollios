class AddVisiblePollToFriend < ActiveRecord::Migration
  def change
    add_column :friends, :visible_poll, :boolean, default: true
  end
end
