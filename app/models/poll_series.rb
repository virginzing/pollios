class PollSeries < ActiveRecord::Base
  include PollSeriesHelper
  attr_accessor :tag_tokens, :same_choices, :expire_within, :group_id

  belongs_to :member
  belongs_to :campaign

  has_many :polls, dependent: :destroy
  has_many :suggests, dependent: :destroy

  has_many :history_view_questionnaires, dependent: :destroy
  has_many :poll_series_tags, dependent: :destroy
  has_many :tags, through: :poll_series_tags, source: :tag

  has_many :history_votes, dependent: :destroy
  has_many :who_voted,  through: :history_votes, source: :member

  has_many :poll_series_groups, dependent: :destroy
  has_many :groups, through: :poll_series_groups, source: :group

  has_many :un_see_polls, as: :unseeable
  has_many :save_poll_laters, as: :savable

  has_one :branch_poll_series, dependent: :destroy
  has_one :branch, through: :branch_poll_series, source: :branch

  has_one :groupping, as: :groupable

  validates :description, presence: true

  accepts_nested_attributes_for :polls, :allow_destroy => true

  self.per_page = 10

  after_create :set_poll_series
  after_create :generate_qrcode_key
  after_commit :send_notification

  amoeba do 
    enable

    set [ {:vote_all => 0}, {:view_all => 0}, {:vote_all_guest => 0}, {:view_all_guest => 0}, {:share_count => 0}, { :comment_count => 0 }, { :created_at => Time.zone.now + 1.days } ]

    include_association [:polls, :branch_poll_series, :groupping]
  end

  def self.filter_by(startdate, finishdate, options)
    startdate = startdate || Date.current
    finishdate = finishdate || Date.current
    
    if options.present?
      startdate = Date.current

      if options == 'today'
        finishdate = Date.current
      elsif options == 'yesterday'
        startdate = Date.current - 1.day
        finishdate = startdate
      elsif options == 'week'
        startdate = Date.current.at_beginning_of_week
        finishdate = Date.current.at_end_of_week
      elsif options == 'month'
        startdate = Date.current.at_beginning_of_month
        finishdate = Date.current.at_end_of_month
      end

    else
      if startdate && finishdate
        startdate = startdate.to_date
        finishdate = finishdate.to_date
      end
    end

    where("date(poll_series.created_at + interval '7 hour') BETWEEN ? AND ?", startdate, finishdate)
  end


  def poll_first
    Poll.find_by(poll_series_id: id, order_poll: 1)  
  end

  def self.get_sum_poll_branch(vote_all, question_count, questionnaire_ids, index)
    array_list = []

    if vote_all == 0
      sum = 0
    else
      PollSeries.where("id IN (?)", questionnaire_ids).each do |ps|
        Poll.unscoped.where("poll_series_id = ?", ps.id).order("polls.order_poll asc").includes(:choices).each do |poll|    
          array_list << poll.choices.collect!{|e| e.answer.to_i * e.vote.to_f }.reduce(:+).to_f
        end
      end

      sum = (array_list.each_slice(question_count).to_a.collect{ |e| e[index] }.reduce(:+) / vote_all).round(2)
    end
    sum
  end

  def get_branch
    branch.present? ? 'สาขา ' + branch.name : nil
  end

  def get_description
    if branch_poll_series.present?
      "[" << branch_poll_series.branch.name << "]" << " " << description
    else
      description
    end
  end

  def send_notification
    unless Rails.env.test?
      self.in_group_ids.split(",").each do |group_id|
        ApnQuestionnaireWorker.perform_async(self.member_id, self.id, group_id) unless self.qr_only
      end
    end 
  end

  def generate_qrcode_key
    begin
      self.qrcode_key = SecureRandom.hex(4)
    end while PollSeries.exists?(qrcode_key: qrcode_key)
    self.update(qrcode_key: qrcode_key)
  end

  def tag_tokens=(tokens)
    puts "tokens => #{tokens}"
    self.tag_ids = Tag.ids_from_tokens(tokens)
  end

  def creator
    member.as_json(only: [:id, :fullname, :avatar])
  end

  def get_link
    # get_link_for_qr_code_series
    GenerateQrcodeLink.new(self).get_link
  end

  # def get_link_for_qr_code_series
  #   if Rails.env.production?
  #     "http://pollios.com/m/polls?key=" << secret_qrcode_key
  #   else
  #     "http://localhost:3000/m/polls?key=" << secret_qrcode_key
  #   end
  # end

  # def secret_qrcode_key
  #   string = "id=" + self.qrcode_key + "&s=t"
  #   Base64.urlsafe_encode64(string)
  # end

  def set_poll_series
    begin
      self.number_of_poll = polls.count
      self.save
      list_choice = self.same_choices
      order_poll = 1

      Poll.unscoped.where("polls.poll_series_id = ?", self.id).order("id asc").each do |poll|
        if list_choice.present?
          list_choice.collect{ |answer| poll.choices.create!(answer: answer) }
          choices_count = list_choice.count
        else
          choices_count = poll.choices.count
        end
        poll.update!(order_poll: order_poll, qr_only: qr_only, require_info: require_info, expire_date: expire_date, series: true, choice_count: choices_count, public: self.public, in_group_ids: self.in_group_ids, campaign_id: self.campaign_id, in_group: self.in_group, member_type: Member.find(self.member_id).member_type_text, qrcode_key: poll.generate_qrcode_key)
        order_poll += 1
      end
    end

    unless qr_only
      @min_poll_id = polls.reload.select {|poll| poll if poll.order_poll }.min.id
      # puts "poll min => #{polls.select{|poll| poll if poll.order_poll }}"
      PollMember.create!(member_id: self.member_id, poll_id: @min_poll_id, share_poll_of_id: 0, public: self.public, series: true, expire_date: expire_date, in_group: self.in_group, poll_series_id: self.id)
      add_questionnaire_to_group if in_group
    end
  end

  def add_questionnaire_to_group
    in_group_ids.split(",").each do |group_id|
      PollGroup.create!(member_id: self.member_id, poll_id: @min_poll_id, share_poll_of_id: 0, group_id: group_id)
    end
  end

  def cached_tags
    Rails.cache.fetch([self, 'tags']) do
      tags.pluck(:name)
    end
  end

  def self.view_poll(member, poll_series)
    member_id = member.id
    poll_series_id = poll_series.id

    used_to_view_qn = HistoryViewQuestionnaire.where(member_id: member_id, poll_series_id: poll_series_id).first_or_create do |hqn|
      hqn.member_id = member_id
      hqn.poll_series_id = poll_series_id
      hqn.save!
      poll_series.update_columns(view_all: poll_series.view_all + 1)
      CollectionPoll.update_sum_view(poll_series)
    end
  end

  def vote_questionnaire(params, member, poll_series)
    surveyed_id = params[:surveyed_id] || params[:member_id]
    member_id = params[:member_id]

    PollSeries.transaction do
      list_answer = params[:answer].collect!{ |poll| poll.merge({ member_id: surveyed_id, surveyor_id: member_id }) }
      list_answer.each do |answer|
        @votes = Poll.vote_poll(answer, member)
      end

      if @votes.present?
        self.increment!(:vote_all)
        poll_series.suggests.create!(member_id: surveyed_id, message: params[:suggest])
        CollectionPoll.update_sum_vote(poll_series)
        SavePollLater.delete_save_later(member_id, poll_series)
        member.flush_cache_my_vote
        member.flush_cache_my_vote_all
        # Activity.create_activity_poll_series(member, poll_series, 'Vote')
      else
        return false
      end
      @votes
    end
  end

  def poll_is_where
    if public
      PollType.to_hash(PollType::WHERE[:public])
    else
      if in_group != true
        PollType.to_hash(PollType::WHERE[:friend_following])
      else
        PollType.to_hash(PollType::WHERE[:group])
      end
    end
  end

  def check_status_survey

    @init_member_suveyable = Surveyor::MembersSurveyableQuestionnaire.new(self)

    @members_surveyable = @init_member_suveyable.get_members_in_group.to_a.map(&:id)

    @members_voted = @init_member_suveyable.get_members_voted.to_a.map(&:id)

    remain_can_survey = @members_surveyable - @members_voted

    complete_status = remain_can_survey.count > 0 ? false : true

    {
      complete: complete_status,
      member_voted: @members_voted.count,
      member_amount: @members_surveyable.count 
    }
  end

  def as_json options={}
    { creator: polls.first.cached_member,
      list_of_poll: {
        id: id,
        vote_count: vote_all,
        view_count: view_all,
        expire_date: expire_date,
        created_at: created_at.to_i,
        title: description,
        series: true,
        tags: cached_tags,
        share_count: share_count,
        poll: polls.as_json()
      }
      }
  end

end
