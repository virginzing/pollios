class AddPersonalProfileToMember < ActiveRecord::Migration
  def change
    add_column :members, :gender, :integer
    add_column :members, :province, :integer
    add_column :members, :birthday, :date
    add_column :members, :interests, :text
    add_column :members, :salary, :integer
  end
end
