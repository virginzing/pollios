class Branch < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: [:slugged, :finders]

  belongs_to :company


  def slug_candidates
    [:name,
     :id, :name]
  end
  
end
