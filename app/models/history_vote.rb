class HistoryVote < ActiveRecord::Base

  belongs_to :member, touch: true
  belongs_to :poll
  belongs_to :poll_series
  belongs_to :choice
  
  store_accessor :data_analysis

  validates :poll_id, :member_id, :choice_id, presence: true

  default_scope { order("#{table_name}.id desc") }

  %w[gender province].each do |key|
    scope "has_#{key}", lambda { |value| where("data_analysis @> hstore(?,?)", key, value) }
  end

  # def self.voted?(member, poll_id)
  #   cached_history_voted = member.cached_my_voted

  #   ever_voted = cached_history_voted.select! {|voted| voted.poll_id == poll_id }

  #   if ever_voted.empty?
  #     {
  #       "voted" => false
  #     }
  #   else
  #     {
  #       "voted" => true, 
  #       "choice_id" => ever_voted[0].choice_id
  #     }
  #   end
  # end

  def self.get_gender_analysis(poll_id, choice_id, gender_type)
    HistoryVote.where("poll_id = #{poll_id} AND choice_id = #{choice_id}").has_gender(gender_type)
  end

  rails_admin do
    list do
      filters [:member, :poll, :choice]
      field :id

      field :member do
        searchable :fullname
        pretty_value do
          %{<a href="/admin/member/#{value.id}">#{value.fullname}</a>}.html_safe
        end
      end

      field :poll

      field :choice do
        searchable :answer
        pretty_value do
          %{<a href="/admin/choice/#{value.id}">#{value.answer}</a>}.html_safe
        end
      end
      field :created_at do
        pretty_value do
          ActionController::Base.helpers.time_ago_in_words(bindings[:object].created_at) + ' ago'
        end
      end
    end
  end

end