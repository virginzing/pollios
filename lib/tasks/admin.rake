namespace :admin do
  desc "create admin"
  task create: :environment do
    Admin.create!(email: "admin@code-app.com", password: "mefuwfhfu", password_confirmation: "mefuwfhfu")
  end

  desc "update follow pollios"
  task follow_pollios: :environment do
    Member.all.each do |member|
      find_pollios = Member.find_by_email("pollios@pollios.com")

      find_used_follow_pollios = Friend.where(follower_id: member.id, followed_id: find_pollios.id, following: false).having_status(:friend).first

      if find_pollios.present?
        if find_used_follow_pollios.present?
          find_used_follow_pollios.update(following: true)
        else
          unless Friend.where(follower_id: member.id, followed_id: find_pollios.id, following: true).first.present?
            Friend.create!(follower_id: member.id, followed_id: find_pollios.id, status: :nofriend, following: true) unless member.id == find_pollios.id
          end
        end
      end

    end
  end

end