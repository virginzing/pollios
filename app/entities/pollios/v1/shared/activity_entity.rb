module Pollios::V1::Shared
  class ActivityEntity < Pollios::V1::BaseEntity

    expose :poll, with: PollForActivityEntity
    expose :action
    with_options(format_with: :as_integer) do
      expose :activity_at
    end

    def poll
      object
    end

  end
end