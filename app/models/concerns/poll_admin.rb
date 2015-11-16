module PollAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        filters [:member, :title]
        field :id

        field :member do
          searchable :fullname
          pretty_value do
            %(<a href="/admin/member/#{value.id}">#{value.fullname}</a>).html_safe
          end
        end

        field :title
        field :public
        field :photo_poll
        field :vote_all
        field :view_all
        field :created_at do
          pretty_value do
            ActionController::Base.helpers.time_ago_in_words(bindings[:object].created_at) + ' ago'
          end
        end
      end

      edit do
        field :title
        field :vote_all
        field :view_all
        field :comment_count
        field :public
        field :status_poll
        field :allow_comment
        field :expire_status
        field :creator_must_vote
        field :priority
        field :draft
        field :system_poll
        field :deleted_at
        field :close_status
        field :created_at
      end
    end
  end
end