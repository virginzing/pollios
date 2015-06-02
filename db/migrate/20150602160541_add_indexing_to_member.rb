class AddIndexingToMember < ActiveRecord::Migration
  def change
    add_index :members, :member_type, where: "member_type = 3"
    add_index :members, :status_account, where: "status_account = 0"
    add_index :members, :sync_facebook, where: "sync_facebook = true"
    add_index :members, :first_signup, where: "first_signup = true"
    add_index :members, :subscription, where: "subscription = true"
    add_index :members, :update_personal, where: "update_personal = true"
    add_index :members, :fb_id
    add_index :members, :show_recommend, where: "show_recommend = true"
  end
end
