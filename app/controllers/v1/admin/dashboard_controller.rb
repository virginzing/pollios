module V1::Admin
  class DashboardController < V1::AdminController
    layout 'v1/admin/navbar_sidebar'

    def index
      @current_page = 'dashboard'

      admin_stats = Admin::Stats.new()
      @stats = admin_stats.dashboard
    end
  end
end
