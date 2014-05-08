class AddIndexAndUniqeOfApitokenOfApnDevice < ActiveRecord::Migration
  def change
    add_index :providers, :token, unique: true
  end
end
