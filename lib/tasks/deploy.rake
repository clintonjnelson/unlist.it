require 'paratrooper'

namespace :deploy do
  desc 'Deploy app in staging environment'
  task :staging do
    deployment = Paratrooper::Deploy.new("unlist-it-staging") do |deploy|
      deploy.tag   = 'staging'
    end
    deployment.deploy
  end

  desc 'Deploy app in production environment'
  task :production do
    deployment = Paratrooper::Deploy.new("unlist-it") do |deploy|
      deploy.tag        = 'production'  #notes the production deploy for tracking
      deploy.match_tag  = 'staging'     #notes the production deploy in staging for tracking
    end
    deployment.deploy
  end
end
