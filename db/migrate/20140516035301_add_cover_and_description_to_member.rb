class AddCoverAndDescriptionToMember < ActiveRecord::Migration
  def change
    add_column :members, :cover, :string
    add_column :members, :description, :text
  end
end
