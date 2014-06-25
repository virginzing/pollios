class CreateMemberReportPolls < ActiveRecord::Migration
  def change
    create_table :member_report_polls do |t|
      t.references :member, index: true
      t.references :poll, index: true

      t.timestamps
    end
  end
end
