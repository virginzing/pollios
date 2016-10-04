module V1::Admin::Polls
  class GetController < V1::AdminController
    layout 'v1/admin/main'

    def index
      @current_page = 'polls'
    end
  end
end
