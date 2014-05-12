class AddPollPublicRequestAtToMember < ActiveRecord::Migration
  def change
    add_column :members, :poll_public_req_at, :datetime
    add_index :members, :poll_public_req_at
  end
end
