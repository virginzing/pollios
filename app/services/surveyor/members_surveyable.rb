class Surveyor::MembersSurveyable
  def initialize(poll, surveyor, params = {})
    @poll = poll
    @surveyor = surveyor
    @params = params
  end

  def get_members_in_group
    @get_member_in_group ||= members_in_group
  end

  def get_members_voted
    member_ids = check_member_that_in_group

    Member.where(id: member_ids)
  end

  def check_member_that_in_group
    members_voted.map(&:id) & get_members_in_group.map(&:id)
  end

  def survey
    poll_id = @poll.id
    choice_id = @params[:choice_id]
    surveyed_id = @params[:surveyed_id]
    data_options = @params[:data_options]

    Poll.transaction do
      begin
        ever_vote = HistoryVote.find_by(member_id: surveyed_id, poll_id: poll_id)

        unless ever_vote.present?

          find_choice = @poll.choices.find_by(id: choice_id)
          find_surveyed = Member.find_by(id: surveyed_id)

          raise ExceptionHandler::NotFound, "Surveyed not found" unless find_surveyed.present?
          raise ExceptionHandler::NotFound, "Poll not found" unless @poll.present?
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
          find_surveyed.flush_cache_my_vote_all

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
    Member.includes(:groups).where("groups.id IN (?) AND group_members.active = 't'", poll_in_group).uniq.references(:groups)
  end

  def members_voted
    @poll.who_voted
  end

  def poll_in_group
    @poll.in_group_ids.split(",")
  end


end
