class AddSearchIndexToTags < ActiveRecord::Migration
  def up
    execute "create index tags_name on tags using gin(to_tsvector('english', name))"
    execute "create index members_fullname on members using gin(to_tsvector('english', fullname))"
    execute "create index members_email on members using gin(to_tsvector('english', email))"
    execute "create index members_username on members using gin(to_tsvector('english', username))"
  end

  def down
    execute "drop index tags_name"
    execute "drop index members_fullname"
    execute "drop index members_email"
    execute "drop index members_username"
  end
end
