class AddPersonalProfileToMember < ActiveRecord::Migration
  def change
    remove_column :members, :gender
    remove_column :members, :birthday
    remove_column :members, :province_id

    add_column :members, :gender, :integer
    add_column :members, :province, :integer
    add_column :members, :birthday, :date
    add_column :members, :interests, :text
    add_column :members, :salary, :integer
  end
end
