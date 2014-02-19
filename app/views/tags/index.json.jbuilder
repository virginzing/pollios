json.array! @tags do |json, tag|
  json.id tag.id
  json.text tag.name
end
