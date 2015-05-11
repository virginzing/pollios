class RemoveShowRecommendToCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :show_recommend
  end
end
