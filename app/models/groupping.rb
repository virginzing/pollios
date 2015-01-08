class Groupping < ActiveRecord::Base
  belongs_to :collection_poll
  belongs_to :groupable, polymorphic: true

  def self.only_questionnaire_ids(collection_poll_id)
    where(collection_poll_id: collection_poll_id, groupable_type: 'PollSeries').pluck(:groupable_id)
  end

end
