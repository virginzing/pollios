class DropTableHiddenPolls < ActiveRecord::Migration
  def change
    drop_table(:hidden_polls)
  end
end
