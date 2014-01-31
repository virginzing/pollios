class AddBirthdayToMember < ActiveRecord::Migration
  def change
    add_column :members, :birthday, :date
  end
end
