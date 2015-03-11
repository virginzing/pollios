class AddRedeemMyselfToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :redeem_myself, :boolean,  default: false
  end
end
