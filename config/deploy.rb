set :stages, %w(staging production)
set :default_stage, "staging"

require "capistrano/ext/multistage"
#require "thinking_sphinx/deploy/capistrano"
require "bundler/capistrano"
#require "bugsnag/capistrano"

set :application, "plakatt"

set :user, "p.sai5757@gmail.com"
set :use_sudo, false

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :repository, "git@github.com:vijaypapasani/my_refineycms.git"
set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache

set :keep_releases, 10

# Deployment
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    #run "ln -nfs #{shared_path}/config/#{rails_env}_config.yml #{release_path}/config/#{rails_env}_config.yml"
   # run "ln -nfs #{shared_path}/db/sphinx #{release_path}/db/sphinx"
  end

  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"
  end

  desc "Restart resque workers with upstart"
  task :restart_resque_workers do
    sudo "restart resque ID=0"
  end

  task :post_deploy_tasks do
    symlink_shared
    update_crontab
    restart_resque_workers
  end
end

before "deploy:update_code", "thinking_sphinx:stop"
before "deploy:assets:precompile", "deploy:symlink_shared"

after "deploy:update_code", "deploy:post_deploy_tasks"
after "deploy:setup", "thinking_sphinx:index"
after "deploy:post_deploy_tasks", "thinking_sphinx:start"

set :whenever_command, "bundle exec whenever"
set :whenever_environment, defer { stage }
