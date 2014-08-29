class CreateMentions < ActiveRecord::Migration
  def change
    create_table :mentions do |t|
      t.references :comment, index: true
      t.integer :mentioner_id
      t.string :mentioner_name
      t.integer :mentionable_id
      t.string :mentionable_name
      t.timestamps
    end

    add_index :mentions, [:mentioner_id, :mentionable_id]
  end
end
