class AddCompanyIdToRecurring < ActiveRecord::Migration
  def change
    add_column :recurrings, :company_id, :integer, index: true
    add_column :poll_series, :recurring_id, :integer, index: true
  end
end
