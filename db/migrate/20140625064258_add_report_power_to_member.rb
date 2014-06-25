class AddReportPowerToMember < ActiveRecord::Migration
  def change
    add_column :members, :report_power, :integer, default: 1
  end
end
