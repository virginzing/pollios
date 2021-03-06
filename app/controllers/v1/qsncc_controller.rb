module V1
  class QsnccController < V1::ApplicationController
    layout 'v1/qsncc'

    before_action :set_meta
    before_action :set_group_qsncc
    before_action :validate_group
    before_action :must_be_admin, only: [:close]
    before_action :must_has_active_polls, only: [:get, :close]
    before_action :must_has_closed_polls, only: [:result]

    def get
      @show_close_poll_button = v1_admin_signed_in?
      @poll = @group_qsncc.current_poll
      @group_public_id = @group_qsncc.group_public_id

      @close_poll_url = @group_qsncc.close_poll_url
    end

    def close
      @group_qsncc.close_current_poll
      redirect_to(action: 'result', group_public_id: params[:group_public_id])
    end

    def result
      @show_next_poll_button = v1_admin_signed_in? && !@group_qsncc.all_polls_already_close?
      @next_poll_url = @group_qsncc.next_poll_url

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
      @group_qsncc ||= ::Group::QSNCC.new(params[:group_public_id])
    end

    def validate_group
      return render('error', locals: { message: 'ไม่พบกลุ่มที่ต้องการ'}) if @group_qsncc.group.nil?
      return render('error', locals: { message: 'ยังไม่มีโพลเกิดขึ้น'}) unless @group_qsncc.has_polls?
    end

    def must_be_admin
      return redirect_to(action: 'get') unless v1_admin_signed_in?
    end

    def must_has_active_polls
      return redirect_to(action: 'result') if @group_qsncc.all_polls_already_close?
    end

    def must_has_closed_polls
      return redirect_to(action: 'get') if @group_qsncc.no_closed_poll?
    end
  end
end
