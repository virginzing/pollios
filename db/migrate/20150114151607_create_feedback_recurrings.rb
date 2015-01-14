class CreateFeedbackRecurrings < ActiveRecord::Migration
  def change
    create_table :feedback_recurrings do |t|
      t.references :company, index: true
      t.time :period
      t.boolean :status

      t.timestamps
    end
  end
end
