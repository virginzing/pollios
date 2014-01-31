json.group_id group.id
json.name_group group.name
json.photo_group group.photo_group.present? ? @group.photo_group.url(:thumbnail) : "No Image Group"
json.created_at group.created_at
json.created_by group.cached_created_by