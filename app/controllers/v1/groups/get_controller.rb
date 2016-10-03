module V1::Groups
  class GetController < V1::ApplicationController
    layout 'v1/groups/main'

    before_action :set_group, only: [:detail]
    before_action :set_meta

    def detail
      puts @group_qsncc.inspect
    end

    private

    def set_meta
      title = @group_qsncc.group.name
      description = @group_qsncc.group.description

      @meta ||= { title: title, description: description }
    end

    def set_group
      @group_qsncc = ::Group::QSNCC.new(params[:group_id])
    end
  end
end
