class CreateRequestCodes < ActiveRecord::Migration
  def change
    create_table :request_codes do |t|
      t.references :member, index: true
      t.text :custom_properties

      t.timestamps
    end
  end
end
