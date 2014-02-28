class AddTypeSeriesToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :type_series, :integer, default: 0
  end
end
