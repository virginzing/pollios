class AddTypePollToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :type_poll, :integer
  end
end
