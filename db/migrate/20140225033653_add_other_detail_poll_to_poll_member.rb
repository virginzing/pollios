class AddOtherDetailPollToPollMember < ActiveRecord::Migration
  def change
    add_column :poll_members, :public, :boolean
    add_column :poll_members, :series, :boolean
    add_column :poll_members, :expire_date, :datetime
  end
end
