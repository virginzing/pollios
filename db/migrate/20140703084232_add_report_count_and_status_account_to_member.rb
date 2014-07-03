class AddReportCountAndStatusAccountToMember < ActiveRecord::Migration
  def change
    add_column :members, :report_count, :integer, default: 0
    add_column :members, :status_account, :integer, default: 1
  end
end
