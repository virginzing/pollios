class AddFeedbackToPollSeries < ActiveRecord::Migration
  def change
    add_column :poll_series, :feedback, :boolean, default: false
  end
end
