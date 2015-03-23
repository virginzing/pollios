class AddMessagePresetToMemberReportPoll < ActiveRecord::Migration
  def change
    add_column :member_report_polls, :message_preset, :string
  end
end
