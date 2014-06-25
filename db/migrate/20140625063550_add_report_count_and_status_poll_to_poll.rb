class AddReportCountAndStatusPollToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :report_count, :integer, default: 0
    add_column :polls, :status_poll, :integer, default: 0
  end
end
