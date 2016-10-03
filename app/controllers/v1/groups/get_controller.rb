module V1::Groups
  class GetController < V1::ApplicationController
    layout 'v1/groups/main'

    before_action :set_group
    before_action :set_meta
    before_action :set_poll, only: [:poll_detail]

    def detail
    end

    def poll_detail
      render('v1/groups/get/polls/detail')
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
  end
end
