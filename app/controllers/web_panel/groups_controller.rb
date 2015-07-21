module WebPanel
  class GroupsController < ApplicationController
    skip_before_action :verify_authenticity_token

    def load_group
      @group = Group.cached_find(params[:group_id])
      render layout: false
    end
  end
end
