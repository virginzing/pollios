class CreateMemberRecentRequests < ActiveRecord::Migration
  def change
    create_table :member_recent_requests do |t|
      t.references :member, index: true
      t.references :recent, polymorphic: true, index: true

      t.timestamps
    end
  end
end
