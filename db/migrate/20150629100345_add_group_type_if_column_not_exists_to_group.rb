class AddGroupTypeIfColumnNotExistsToGroup < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:groups, :group_type)
      add_column :groups, :group_type, :integer
    end

    add_index :groups, :group_type, where: "group_type = 1"
    add_index :groups, :need_approve, where: "need_approve = false"
  end
end
