class AddApproveCompanyAndApproveBrandToMember < ActiveRecord::Migration
  def change
    add_column :members, :approve_brand, :boolean, default: false
    add_column :members, :approve_company, :boolean, default: false
  end
end
