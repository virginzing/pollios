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

  def apple_hash
    result = {}
    result['aps'] = {}
    result['aps']['alert'] = self.alert if self.alert
    result['aps']['badge'] = self.badge.to_i if self.badge
    # add content available is 1 default
    # result['aps']['content-available'] = 1 if self.content_available
    result['aps']['content-available'] = 1

    if self.sound
      result['aps']['sound'] = self.sound if self.sound.is_a? String
      result['aps']['sound'] = "1.aiff" if self.sound.is_a?(TrueClass)
    end
    if self.custom_properties
      self.custom_properties.each do |key,value|
        result["#{key}"] = "#{value}"
      end
    end
    result
  end

end