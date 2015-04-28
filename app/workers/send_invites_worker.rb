class SendInvitesWorker
  include Sidekiq::Worker

  def perform(list_email, group_id, company_id)

    group = Group.find(group_id)
    company = Company.find(company_id)

    list_invite_code ||= InviteCode.add_more_invite_code(list_email.size, company.id).collect{|e| e.code }
    # puts "#{list_email}"
    list_email.each_index do |e|
      MemberMailer.delay.send_invite_group(list_email[e], group.name, list_invite_code[e] )
    end

  end
  
  
end

# SendInvitesWorker.perform_async(["nuttapon@code-app.com", "greannut@gmail.com"], 62,12)