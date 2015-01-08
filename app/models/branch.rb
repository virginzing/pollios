class Branch < ActiveRecord::Base
  # extend FriendlyId
  # friendly_id :slug_candidates, use: [:slugged, :finders]

  belongs_to :company

  has_many :branch_polls, dependent: :destroy
  
  has_many :branch_poll_series, dependent: :destroy
  
  has_many :questionnaires, through: :branch_poll_series, source: :poll_series
  # def slug_candidates
  #   [:name,
  #    :id, :name]
  # end

  # def should_generate_new_friendly_id?
  #   name_changed? || super
  # end
  
  def get_questionnaire_count
    branch_poll_series.uniq.count
  end

  def get_poll_count
    branch_polls.uniq.count
  end
end
