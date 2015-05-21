class CreatePollSeriesCompanies < ActiveRecord::Migration
  def change
    create_table :poll_series_companies do |t|
      t.references :poll_series, index: true
      t.references :company, index: true
      t.string :post_from

      t.timestamps
    end
  end
end
