class RemoveShowRecommendToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :show_recommend, :boolean, default: false
    remove_column :companies, :show_recommend
  end
end
