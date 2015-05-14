class AddAnnouceOnToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :announce_on, :datetime
  end
end
