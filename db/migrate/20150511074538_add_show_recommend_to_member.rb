class AddShowRecommendToMember < ActiveRecord::Migration
  def change
    add_column :members, :show_recommend, :boolean, default: false
  end
end
