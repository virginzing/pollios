module Api
  module V1
    class SurveyorsController < ApplicationController
      respond_to :json

      skip_before_action :verify_authenticity_token
    
      before_action :set_current_member
      before_action :compress_gzip, if: :request_json?

      def list_polls
        @init_poll = PollOfGroup.new(@current_member, find_group_that_surveyor, options_params)
        # @polls = @init_poll.get_poll_of_group_company.paginate(page: params[:next_cursor])
        @polls = @init_poll.get_poll_of_group_company
        # @next_cursor = @polls.next_page.nil? ? 0 : @polls.next_page
        # @total_entries = @polls.total_entries
      end

      def poll_detail
        
      end


      def members_surveyable
        @init_member_suveyable = Surveyor::MembersSurveyable.new(set_poll, @current_member)
        @members_surveyable = @init_member_suveyable.get_members_in_group

        @members_voted = @init_member_suveyable.get_members_voted
      end

      def members_surveyable_questionnaire
        @init_member_suveyable = Surveyor::MembersSurveyableQuestionnaire.new(set_quesitonnaire)
        @members_surveyable = @init_member_suveyable.get_members_in_group

        @members_voted = @init_member_suveyable.get_members_voted
      end

      def survey
        @init_survey = Surveyor::MembersSurveyable.new(set_poll, @current_member, survey_params)
        @survey = @init_survey.survey
      end

      def list_of_survey
        @init_list_survey = Surveyor::MembersListSurveyable.new(@current_member, list_survey_params.slice(:list_survey))
        @list_survey = @init_list_survey.survey_all
      end

      private

      def find_group_that_surveyor
        @current_member.surveyor_in_group
      end

      def options_params
        params.permit(:next_cursor, :type, :member_id, :since_id, :pull_request)
      end

      def survey_params
        params.permit(:member_id, :surveyed_id, :choice_id, :data_options)
      end

      def list_survey_params
        params.permit(:member_id, :id, list_survey: [ :poll_id, :list_voted => [:surveyed_id, :choice_id]])
      end

      def set_poll
        @poll = Poll.find_by(id: params[:id])
        raise ExceptionHandler::NotFound, "Poll not found" unless @poll.present?
        @poll
      end

      def set_quesitonnaire
        @questionnaire = PollSeries.find_by(id: params[:id])
        raise ExceptionHandler::NotFound, "Questionnaire not found" unless @questionnaire.present?
        @questionnaire
      end

      def request_json
        request.format.json?
      end

    end
  end
end