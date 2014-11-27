class Surveyor::MembersListSurveyable
  def initialize(surveyor, params = {})
    @surveyor = surveyor
    @params = params
  end
  
  def list_survey
    @params[:list_survey] || []
  end

  def data_options
    @params[:data_options]
  end

  def survey_all
    Poll.transaction do
      list_survey.each do |survey|
        poll_id = survey[:poll_id]
        @list_voted = survey[:list_voted]

        @poll = Poll.find_by(id: poll_id)

        if @poll.present?
          surveyable
        end

      end

    end
  end

  def surveyable
    @list_voted.each do |voted|
      surveyed_id = voted[:surveyed_id]
      choice_id = voted[:choice_id]

      unless HistoryVote.exists?(member_id: surveyed_id, poll_id: @poll.id)
        begin
          find_choice = @poll.choices.find_by(id: choice_id)
          find_surveyed = Member.find_by(id: surveyed_id)

          raise ExceptionHandler::NotFound, "Surveyed not found" unless find_surveyed.present?
          raise ExceptionHandler::NotFound, "Choice not found" unless find_choice.present?

          poll_series_id = @poll.series ? @poll.poll_series_id : 0

          find_surveyed.history_votes.create!(poll_id: @poll.id, choice_id: choice_id, poll_series_id: poll_series_id, data_analysis: data_options, surveyor_id: @surveyor.id)

          @poll.increment!(:vote_all)

          find_choice.increment!(:vote)

          unless @poll.series
            VoteStats.create_vote_stats(@poll)
            Activity.create_activity_poll(find_surveyed, @poll, 'Vote')
          end

          find_surveyed.flush_cache_my_vote
          find_surveyed.flush_cache_my_vote_all

          Rails.cache.delete( ['Poll', @poll.id ] )
          true
        rescue => e
          puts "log error => #{e.message}"
          true
        end
      end

    end
  end
  
end