json.array!(@recurrings) do |recurring|
  json.extract! recurring, :id, :period, :status, :member_id, :end_recur
  json.url recurring_url(recurring, format: :json)
end
