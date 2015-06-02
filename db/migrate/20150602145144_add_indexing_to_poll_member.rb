class AddIndexingToPollMember < ActiveRecord::Migration
  def change
    add_index :poll_members, :public
    add_index :poll_members, :series, where: "series = true"
    add_index :poll_members, :in_group, where: "in_group = true"
    add_index :poll_members, :poll_series_id
  end
end
