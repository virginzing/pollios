class Branch < ActiveRecord::Base
  # extend FriendlyId
  # friendly_id :slug_candidates, use: [:slugged, :finders]

  belongs_to :company

  has_many :branch_poll_series, dependent: :destroy
  

  # def slug_candidates
  #   [:name,
  #    :id, :name]
  # end

  # def should_generate_new_friendly_id?
  #   name_changed? || super
  # end
  
end
