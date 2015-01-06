class Apn::Device < Apn::Base

  belongs_to :member
  
  has_many :notifications, :class_name => 'Apn::Notification', dependent: :destroy

  rails_admin do
    list do
      filters [:member, :token]
      field :id

      field :member do
        searchable :fullname
        pretty_value do
          %{<a href="/admin/member/#{value.id}">#{value.fullname}</a>}.html_safe
        end
      end

      field :token

      field :api_token

      field :created_at do
        pretty_value do
          ActionController::Base.helpers.time_ago_in_words(bindings[:object].created_at) + ' ago'
        end
      end

    end

  end  
end