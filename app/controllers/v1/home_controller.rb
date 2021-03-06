module V1
  class HomeController < V1::ApplicationController
    layout 'v1/navbar_no_sidebar'

    def landing
      @popular_poll = Polls::ListDecorator.decorate_collection(::Shared::PollList.popular_public_polls)
      render 'legacy_landing', layout: 'v1/legacy_home_layout'
    end
  end
end
