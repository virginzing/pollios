class AddExpireToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :expire, :datetime
  end
end
