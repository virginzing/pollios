module V1::Groups
  class PostController < V1::ApplicationController
    before_action :set_group
    before_action :set_meta
    before_action :set_poll
    before_action :must_be_admin, only: [:close_poll]

    def close_poll
      @group_qsncc.close_poll_by_index(params[:index])

      redirect_to(controller: :get, action: :poll_detail_result, group_id: params[:group_id], index: params[:index])
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
      fail ActionController::RoutingError, 'Not Authorize.' unless v1_admin_signed_in?
    end

    def mobile_device?
      request.user_agent =~ /Mobile|webOS/
    end

    def set_chart_height
      @chart_height = mobile_device? ? 500 : 150
    end
  end
end
