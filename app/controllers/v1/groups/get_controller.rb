module V1::Groups
  class GetController < V1::ApplicationController
    layout 'v1/groups/main'

    before_action :set_group
    before_action :set_meta
    before_action :set_poll
    before_action :must_be_admin, only: [:poll_detail_result]
    before_action :set_chart_height, only: [:poll_detail_result]

    def detail
    end

    def poll_detail
      @poll = Polls::DetailDecorator.new(@poll, params[:index], request.host)
      @show_actions_button = v1_admin_signed_in?

      render('v1/groups/get/polls/detail')
    end

    def poll_summary
    end

    def poll_detail_result
      @poll = Polls::ResultDecorator.new(@poll, params[:index], request.host)

      render('v1/groups/get/polls/result')
    end

    private

    def set_meta
      title = @group.name
      description = @group.description

      @meta ||= { title: title, description: description }
    end

    def set_group
      @group_qsncc = ::Group::QSNCC.new(params[:group_id])
      @group = @group_qsncc.group
    end

    def set_poll
      @poll = @group_qsncc.poll_by_index(params[:index])
    end

    def must_be_admin
      return redirect_to(action: :poll_detail) unless v1_admin_signed_in?
    end

    def mobile_device?
      request.user_agent =~ /Mobile|webOS/
    end

    def set_chart_height
      @chart_height = mobile_device? ? 500 : 150
    end
  end
end
