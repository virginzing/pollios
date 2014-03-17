json.id group.id
json.name group.name
json.photo group.photo_group.present? ? @group.photo_group.url(:thumbnail) : nil
json.member_count group.member_count
json.poll_count group.poll_count
json.created_at group.created_at.to_i
json.created_by group.cached_created_by