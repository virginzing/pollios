class AddMessageToMemberReportPoll < ActiveRecord::Migration
  def change
    add_column :member_report_polls, :message, :text
  end
end
