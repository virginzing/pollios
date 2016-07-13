module V1::Shared
  class PollDetailDecorator < V1::ApplicationDecorator

    delegate_all

    def poll
      object
    end

    def share_url
      Poll::DirectAccess.new(poll).share_url
    end
  end
end
