class CreatePollCompanies < ActiveRecord::Migration
  def change
    create_table :poll_companies do |t|
      t.references :poll, index: true
      t.references :company, index: true
      t.string :post_from

      t.timestamps
    end
  end
end
