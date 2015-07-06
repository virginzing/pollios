class AddGroupTypeIfColumnNotExistsToGroup < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.column_exists?(:groups, :group_type)
      add_column :groups, :group_type, :integer
    end

    unless ActiveRecord::Base.connection.index_exists?(:groups, :group_type)
      add_index :groups, :group_type, where: "group_type = 1"
    end

    unless ActiveRecord::Base.connection.index_exists?(:groups, :need_approve)
      add_index :groups, :need_approve, where: "need_approve = false"
    end

  end
end
