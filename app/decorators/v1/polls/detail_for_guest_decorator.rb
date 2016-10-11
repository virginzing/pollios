module V1::Polls
  class DetailForGuestDecorator < V1::ApplicationDecorator
    delegate :title, :member, :get_photo, :choices
  end
end
