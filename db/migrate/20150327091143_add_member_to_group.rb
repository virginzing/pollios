class AddMemberToGroup < ActiveRecord::Migration
  def change
    add_reference :groups, :member, index: true
  end
end
