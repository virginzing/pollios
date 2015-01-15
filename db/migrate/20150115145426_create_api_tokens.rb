class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.references :member, index: true
      t.string :uuid
      t.string :token

      t.timestamps
    end
  end
end
