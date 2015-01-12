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

  def self.filter_by(startdate, finishdate, options)
    startdate = startdate || Date.current
    finishdate = finishdate || Date.current
    
    if options.present?
      startdate = Date.current

      if options == 'today'
        finishdate = Date.current
      end

    else
      if startdate && finishdate
        puts "in branch"
        puts startdate.to_date
        puts finishdate.to_date
        startdate = startdate.to_date
        finishdate = finishdate.to_date
      end
    end

    where("date(poll_series.created_at + interval '7 hour') BETWEEN ? AND ?", startdate, finishdate)
  end
end
