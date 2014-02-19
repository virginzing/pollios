json.array!(@campaigns) do |campaign|
  json.extract! campaign, :id, :name, :photo_campaign, :used, :limit, :member_id
  json.url campaign_url(campaign, format: :json)
end
