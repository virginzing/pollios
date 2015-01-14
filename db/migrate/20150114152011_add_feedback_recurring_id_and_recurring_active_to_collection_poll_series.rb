class AddFeedbackRecurringIdAndRecurringActiveToCollectionPollSeries < ActiveRecord::Migration
  def change
    add_reference :collection_poll_series, :feedback_recurring, index: true
    add_column :collection_poll_series, :recurring_status, :boolean,  default: true
    add_column :collection_poll_series, :recurring_poll_series_set, :string, array: true, default: '{}'
  end
end
