namespace :group do

  desc "Update role to member each group"
  task :update_role => :environment do
    Company.joins(:groups).each do |c|
      c.groups.each do |group|
        group.get_admin_group.collect {|e| e.add_role :group_admin, group }
      end
    end
  end

end
