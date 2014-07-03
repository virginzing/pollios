class CreateMemberReportMembers < ActiveRecord::Migration
  def change
    create_table :member_report_members do |t|
      t.integer :reporter_id
      t.integer :reportee_id
      t.text :message

      t.timestamps
    end
    add_index :member_report_members, :reporter_id
    add_index :member_report_members, :reportee_id
  end
end
