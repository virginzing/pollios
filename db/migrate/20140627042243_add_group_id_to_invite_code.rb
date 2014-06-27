class AddGroupIdToInviteCode < ActiveRecord::Migration
  def change
    add_reference :invite_codes, :group, index: true
  end
end
