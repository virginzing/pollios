class PollForDeleteSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :member, :choices, :title, :public, :vote_all, :view_all, :created_at, :updated_at, :report_count

  def member
    object.member.as_json()
  end

  def choices
    object.choices.as_json()
  end
end
