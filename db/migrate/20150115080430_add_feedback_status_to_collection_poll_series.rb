class AddFeedbackStatusToCollectionPollSeries < ActiveRecord::Migration
  def change
    add_column :collection_poll_series, :feedback_status, :boolean, default: true
  end
end
