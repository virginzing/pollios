module V1::Admin::Dashboard
  class GetController < V1::AdminController
    layout 'v1/admin/main'

    def index
      @current_page = 'dashboard'

      @usage_stats = {
        voted: 103,
        poll_created: 105,
        active_users: 16
      }
    end
  end
end
