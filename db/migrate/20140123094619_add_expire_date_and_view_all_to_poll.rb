class AddExpireDateAndViewAllToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :expire_date, :date
    add_column :polls, :view_all, :integer, default: 0
  end
end
