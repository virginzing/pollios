class ChangeColumnTypeOfActiveToMember < ActiveRecord::Migration
  def change
    change_column :friends, :active, :integer
  end
end
