class AddReportCountToComment < ActiveRecord::Migration
  def change
    add_column :comments, :report_count, :integer,  default: 0
  end
end
