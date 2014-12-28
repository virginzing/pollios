class AddCompanyIdToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :company_id, :integer
    add_index :campaigns, :company_id
  end
end
