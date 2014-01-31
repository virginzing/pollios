class ChangeTypeExpireDateToPoll < ActiveRecord::Migration
  def change
    add_column :polls, :start_date, :datetime, default: Time.now
    change_column :polls, :expire_date, :datetime
  end
end
