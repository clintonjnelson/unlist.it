desc "Heroku scheduler task to give users invitations allotment"
task :issue_invitations => :environment do
  puts "Rationing out invitations to users..."
  settings = Setting.first
  User.all.each do |user|
    distribute_invitations(user, settings)
  end
  puts "done."
end

def distribute_invitations(user, settings)
  max    = settings.invites_max
  ration = settings.invites_ration
  count  = user.invite_count

  if count < max
    count += ration
    if count > max
      user.update_column(:invite_count, max)
    else
      user.update_column(:invite_count, count)
    end
  end
end

#need to define table with:
  #invites_ration
  #invites_max
