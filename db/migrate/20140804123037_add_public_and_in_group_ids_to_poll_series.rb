class AddPublicAndInGroupIdsToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :public, :boolean, default: true
    add_column :poll_series, :in_group_ids, :string,  default: "0"
  end
end
