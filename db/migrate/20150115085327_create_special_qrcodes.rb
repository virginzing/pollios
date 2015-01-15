class CreateSpecialQrcodes < ActiveRecord::Migration
  def change
    create_table :special_qrcodes do |t|
      t.string :code
      t.hstore :info

      t.timestamps
    end
  end
end
