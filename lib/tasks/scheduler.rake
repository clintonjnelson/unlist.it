
require 'rake'
desc "Heroku scheduler task."

################################# INVITATIONS ##################################
task :issue_invitations => :environment do
  puts "Rationing out invitations to users..."

  settings = Setting.first
  User.all.each do |user|
    distribute_invitations(user, settings)
  end

  puts "done."
end

task :thursday_invitations => :environment do
  puts "Rationing out weekly invitations to users..."

  if Date.today.wday == 4
    settings = Setting.first
    User.all.each do |user|
       distribute_invitations(user, settings)
    end
    puts "done."
  else
    puts "still waiting for Thursday..."
  end
end

################################### SITEMAP ####################################
task :refresh_sitemap => :environment do
  puts "Refreshing the sitemap..."
    Rake::Task["sitemap:refresh:no_ping"].invoke
  puts "done."
end

################################### CLEANERS ###################################
desc "Heroku scheduler task to clean out database unimages that never were associated with an Unlisting"
task :wipe_abandoned_unimages => :environment do
  puts "Sweeping the server for abandoned unimages..."

  unclaimed = Unimage.where(unlisting_id: nil).where("updated_at < ?", 1.week.ago).all.map(&:id)
  UnimagesCleaner.perform_async(unclaimed, true)

  puts "done."
end




################################ SUPPORT METHODS ###############################
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
