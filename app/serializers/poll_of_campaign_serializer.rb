class PollOfCampaignSerializer < ActiveModel::Serializer
  self.root = false
  attributes :id, :text

  def text
    object.title
  end

end
