module V1
  class QsnccController < V1::ApplicationController
    layout 'v1/qsncc'

    before_filter :set_group_qsncc
    before_action :set_meta, :validate_group

    def get
      return redirect_to(action: 'result') if @group_qsncc.all_polls_already_close?

      @show_close_poll_button = v1_admin_signed_in?
      @poll = @group_qsncc.current_poll
    end

    def close
      return redirect_to(action: 'get') unless v1_admin_signed_in?

      @group_qsncc.close_current_poll
      redirect_to(action: 'result')
    end

    def result
      return redirect_to(action: 'get') if @group_qsncc.no_closed_poll?

      @show_next_poll_button = v1_admin_signed_in? && !@group_qsncc.all_polls_already_close?
      @poll = QsnccPollDecorator.new(@group_qsncc.recently_closed_poll)
    end

    def polling
      @poll = @group_qsncc.current_poll

      render json: { vote_all: @poll.vote_all }
    end

    private

    def set_meta
      @meta = {
        title: 'Queen Sirikit National Convention Center',
        description: 'Some Description',
        image: 'http://placehold.it/720x300'
      }
    end

    def set_group_qsncc
      @group_qsncc = ::Group::QSNCC.new()
    end

    def validate_group
      return render('not_has_polls') unless @group_qsncc.has_polls?
    end

    def must_be_admin
      return redirect_to(action: 'get') unless v1_admin_signed_in?
    end
  end
end
