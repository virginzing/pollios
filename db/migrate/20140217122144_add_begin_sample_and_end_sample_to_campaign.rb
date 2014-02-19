class AddBeginSampleAndEndSampleToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :begin_sample, :integer, default: 1
    add_column :campaigns, :end_sample, :integer
  end
end
