class AddMemberTypeToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :member_type, :string
  end
end
