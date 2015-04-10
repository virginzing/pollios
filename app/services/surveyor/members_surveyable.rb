class Surveyor::MembersSurveyable
  def initialize(poll, surveyor, params = {})
    @poll = poll
    @surveyor = surveyor
    @params = params
  end

  def surveyor_groups
    @surveyor.group_surveyors
  end

  def get_members_in_group
    @get_member_in_group ||= members_in_group
  end

  def get_members_voted
    member_ids = check_member_that_in_group

    Member.where(id: member_ids)
  end

  def check_member_that_in_group
    members_voted.map(&:id).uniq & get_members_in_group.map(&:id)
  end

  def survey
    poll_id = @poll.id
    choice_id = @params[:choice_id]
    surveyed_id = @params[:surveyed_id]
    data_options = @params[:data_options]

    Poll.transaction do
      begin
        unless HistoryVote.exists?(member_id: surveyed_id, poll_id: poll_id)

          find_choice = @poll.choices.find_by(id: choice_id)
          find_surveyed = Member.find_by(id: surveyed_id)

          raise ExceptionHandler::NotFound, "Surveyed not found" unless find_surveyed.present?
          raise ExceptionHandler::NotFound, ExceptionHandler::Message::Poll::NOT_FOUND unless @poll.present?
          raise ExceptionHandler::NotFound, "Choice not found" unless find_choice.present?

          poll_series_id = @poll.series ? @poll.poll_series_id : 0

          find_surveyed.history_votes.create!(poll_id: poll_id, choice_id: choice_id, poll_series_id: poll_series_id, data_analysis: data_options, surveyor_id: @surveyor.id)

          @poll.increment!(:vote_all)

          find_choice.increment!(:vote)

          unless @poll.series
            VoteStats.create_vote_stats(@poll)
            Activity.create_activity_poll(find_surveyed, @poll, 'Vote')
          end

          find_surveyed.flush_cache_my_vote
          FlushCached::Member.new(find_surveyed).clear_list_voted_all_polls

          Rails.cache.delete( ['Poll', poll_id ] )
          true
        else
          raise ExceptionHandler::Forbidden, "Voted Already"
        end ## unless
      end
    end

  end

  private

  def members_in_group
    join_together_group = surveyor_groups.map(&:group_id) & poll_in_group

    Member.includes(:groups).where("groups.id IN (?) AND group_members.active = 't'", join_together_group).uniq.references(:groups)
  end

  def members_voted
    @poll.who_voted
  end

  def poll_in_group
    @poll.in_group_ids.split(",").collect{|e| e.to_i }
  end


end
