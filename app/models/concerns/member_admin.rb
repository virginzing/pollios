module MemberAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      configure :new_avatar do
        pretty_value do
          bindings[:view].tag(:img, { :src => Member.check_image_avatar(bindings[:object].avatar), :class => 'img-polaroid', width: "50px", height: "50px"})
        end
      end

      list do
        filters [:gender, :member_type, :fullname, :email]
        field :id
        field :new_avatar
        field :fullname
        field :username
        field :email
        field :gender do
          filterable true
          queryable false
        end
        field :member_type do
          filterable true
          queryable false
        end
        field :created_at
      end

      configure :follower do
        visible(false)
      end

      create do
        field :email
        field :fullname
        field :username
        field :gender
        field :member_type
        field :friend_limit
        field :birthday
        field :province
        field :avatar
        field :key_color
      end

      edit do
        field :email do
         read_only true
        end
        field :fullname
        field :username
        field :gender
        field :member_type
        field :friend_limit
        field :birthday
        field :province
        field :avatar, :carrierwave
        field :cover, :carrierwave
        field :cover_preset
        field :description
        field :status_account
        field :blacklist_last_at
        field :blacklist_count
        field :ban_last_at
        field :point
        field :subscription
        field :subscribe_last
        field :subscribe_expire
        field :bypass_invite
        field :approve_brand
        field :approve_company
        field :waiting
        field :first_signup
        field :public_id
        field :fb_id
        field :sync_facebook
        field :show_recommend
        field :key_color
        field :show_search
      end

       show do
        include_all_fields
        exclude_fields :avatar
      end
    end
  end
end