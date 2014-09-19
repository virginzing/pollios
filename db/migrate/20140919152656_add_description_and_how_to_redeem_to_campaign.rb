class AddDescriptionAndHowToRedeemToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :description, :text
    add_column :campaigns, :how_to_redeem, :text
  end
end
