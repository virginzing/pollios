module HistoryVoteAdmin
  extend ActiveSupport::Concern

  included do
    rails_admin do
      list do
        filters [:member, :poll, :choice]
        field :id

        field :member do
          searchable :fullname
          pretty_value do
            %(<a href="/admin/member/#{value.id}">#{value.fullname}</a>).html_safe
          end
        end

        field :poll

        field :choice do
          searchable :answer
          pretty_value do
            %(<a href="/admin/choice/#{value.id}">#{value.answer}</a>).html_safe
          end
        end
        field :data_analysis
        field :surveyor_id
        field :show_result

        field :created_at do
          pretty_value do
            ActionController::Base.helpers.time_ago_in_words(bindings[:object].created_at) + ' ago'
          end
        end
      end
    end
  end
end