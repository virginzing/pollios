module Pollios::V1::PollAPI
  class PollDetailEntity < Pollios::V1::BaseEntity

    expose :creator do |obj, opts|
      Pollios::V1::Shared::MemberEntity.represent creator, current_member_linkage: current_member_linkage
    end

    expose :id, as: :poll_id
    expose :title
    expose :vote_all, as: :vote_count

    with_options(format_with: :as_integer) do
      expose :expire_date
      expose :created_at
    end

    expose :get_vote_max, as: :vote_max, if: -> (object, options) { object.vote_all > 0}
    expose :get_choice_detail, as: :choices
    expose :current_member_voting_detail, as: :voted_detail

    expose :choice_count
    expose :series
    expose :cached_tags, as: :tags
    expose :get_campaign, as: :campaign

    expose :campaign, as: :campaign_detail, with: Pollios::V1::CurrentMemberAPI::CampaignDetailEntity

    expose :public, as: :is_public
    expose :type_poll
    expose :poll_within

    # expose :check_watch

    expose :get_photo, as: :photo
    expose :thumbnail_type
    expose :allow_comment
    expose :comment_count
    expose :get_require_info, as: :require_info
    expose :get_creator_must_vote, as: :creator_must_vote
    expose :show_result
    expose :close_status
    expose :get_original_images, as: :original_images, if: -> (object, options) { object.photo_poll.present? }
  
    def current_member
      @current_member ||= options[:current_member]
    end

    def poll_list_service
      @poll_list_service ||= Member::PollList.new(current_member)
    end

    def thumbnail_type
      object.thumbnail_type || 0
    end

    def current_member_voting_detail
      poll_list_service.voting_detail(object.id)
    end

    def poll_within
      # TODO: Make a proper service method in Poll::Listing
      object.feed_name_for_member(current_member)
    end

    def creator
      Member.cached_find(object.member_id)
    end

    def current_member_linkage
      @current_member_linkage ||= Member::MemberList.new(current_member).social_linkage_ids
    end
  end
end