class AddBlacklistLastAtAndBlacklistCountAndBanLastAtToMember < ActiveRecord::Migration
  def change
    add_column :members, :blacklist_last_at, :datetime
    add_column :members, :blacklist_count, :integer,  default: 0
    add_column :members, :ban_last_at, :datetime
  end
end
