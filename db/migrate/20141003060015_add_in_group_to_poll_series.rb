class AddInGroupToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :in_group, :boolean, default: false
  end
end
