class AddPollOverallRequestAtToMember < ActiveRecord::Migration
  def change
    add_column :members, :poll_overall_req_at, :datetime, default: Time.now
    add_index :members, :poll_overall_req_at
  end
end
