class CreateMemberReportComments < ActiveRecord::Migration
  def change
    create_table :member_report_comments do |t|
      t.references :member, index: true
      t.references :poll, index: true
      t.references :comment, index: true
      t.text :message
      t.text :message_preset

      t.timestamps
    end
  end
end
