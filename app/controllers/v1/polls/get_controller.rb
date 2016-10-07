module V1::Polls
  class GetController < V1::ApplicationController
    layout 'v1/main'

    rescue_from ExceptionHandler::UnprocessableEntity, with: :handle_status_422

    before_action :set_poll
    before_action :set_poll_direct_access
    before_action :current_member_poll_action

    before_action do
      set_meta(
        title: @poll.title,
        description: @poll.member.fullname,
        url: request.original_url,
        image: @poll_direct_access.qrcode_image_url
      )
    end

    def detail
      @poll_open_app_url = @poll_direct_access.open_app_url
      @poll_qrcode_image_url = @poll_direct_access.qrcode_image_url

      @poll = DetailDecorator.decorate(@poll)
    end

    def vote
      poll = @current_member_poll_action.vote(vote_params)
      render json: { poll: poll }
    end

    private

    def decode_poll_id(custom_key)
      Base64.urlsafe_decode64(custom_key).to_i - ENV['POLL_URL_ENCODER_KEY'].to_i
    end

    def set_poll_direct_access
      @poll_direct_access ||= ::Poll::DirectAccess.new(@poll)
    end

    def set_poll
      @poll ||= ::Poll.find_by(id: decode_poll_id(params[:custom_key]))
    end

    def current_member_poll_action
      @current_member_poll_action ||= ::Member::PollAction.new(@current_member, @poll)
    end

    def vote_params
      params.permit(:choice_id)
    end

    def handle_status_422(e)
      flash[:type] = 'error'
      flash[:message] = e.message

      redirect_to :back
    end
  end
end
