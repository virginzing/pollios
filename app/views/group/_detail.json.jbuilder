json.id group.id
json.name group.name
json.photo group.photo_group.present? ? @group.photo_group.url(:thumbnail) : "No Image Group"
json.created_at group.created_at
json.created_by group.cached_created_by