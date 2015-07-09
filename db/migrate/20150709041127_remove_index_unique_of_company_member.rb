class RemoveIndexUniqueOfCompanyMember < ActiveRecord::Migration
  def change
    remove_index :company_members, :member_id
  end
end
