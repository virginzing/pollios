class Apn::Notification < Apn::Base
  rails_admin do
    list do
      filters [:device, :alert]
      field :id

      field :device do
        pretty_value do
          if bindings[:object].device.present?
            %{<a href="/admin/member/#{bindings[:object].device.member.id}">#{bindings[:object].device.member.fullname}</a>}.html_safe
          end
        end
      end

      field :alert

      field :sent_at do
        pretty_value do
          ActionController::Base.helpers.time_ago_in_words(bindings[:object].sent_at) + ' ago'
        end
      end

      field :created_at do
        pretty_value do
          ActionController::Base.helpers.time_ago_in_words(bindings[:object].created_at) + ' ago'
        end
      end

    end

  end
end