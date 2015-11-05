module Pollios::V1::Shared
  class RewardDetailEntity < Pollios::V1::BaseEntity
    expose :title
    expose :detail
    with_options(format_with: :as_integer) do
      expose :reward_expire, as: :expire
    end
    expose :redeem_myself

    def redeem_myself
      options[:redeem_myself] ? options[:redeem_myself] : false
    end
  end
end