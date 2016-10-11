module V1::Polls
  class PostController < V1::ApplicationController

    before_action :poll
    before_action :current_member_poll_action

    def vote
      @current_member_poll_action.vote(vote_params)

      redirect_to :back
    end

    private
    
    def decode_poll_id(custom_key)
      Base64.urlsafe_decode64(custom_key).to_i - ENV['POLL_URL_ENCODER_KEY'].to_i
    end

    def poll
      @poll ||= ::Poll.find(decode_poll_id(params[:custom_key]))
    end

    def current_member_poll_action
      @current_member_poll_action ||= ::Member::PollAction.new(@current_member, @poll)
    end

    def vote_params
      params.permit(:choice_id)

      params[:choice_id] = params[:choice_id].to_i unless params[:choice_id].nil?

      params
    end
  end
end
