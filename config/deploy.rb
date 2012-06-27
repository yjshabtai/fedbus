set :application, "FedBus"
set :repository,  "git@github.com:bradkrane/fedbus.git"

set :scm, :git

set :bundle_cmd, "/var/lib/gems/1.9.1/bin/bundle"

set :use_sudo, false

set :skip_db_setup, true

default_run_options[:pty] = true

require 'bundler/capistrano'
#require 'config/deploy/capistrano_database_yml'

#Symlink shared resources
#Shared folders must be terminated with a / otherwise a file is assumed
set :shared_assets, ["lib/keys.rb", "config/database.yml", "config/initializers/secret_token.rb"]

namespace :assets  do
  namespace :symlinks do
    desc "Setup application symlinks for shared assets"
    task :setup, :roles => [:app, :web] do
      shared_assets.each { |link| 
        if link[-1] == '/'
          link=link[0..-2]
          run "mkdir -p #{shared_path}/#{link}"
        else
          run "touch #{shared_path}/#{link}"
        end
      }
    end

    desc "Link assets for current deploy to the shared location"
    task :update, :roles => [:app, :web] do
      shared_assets.each { |link| 
        run "ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"
      }
    end
  end
end

after "deploy:assets:symlink" do
  assets.symlinks.setup
  assets.symlinks.update
end

after "deploy:create_symlink" do
  assets.symlinks.update
end


task :dev do
  server "www-app.fs.uwaterloo.ca", :web, :app
  role :db, "www-app.fs.uwaterloo.ca", :primary => true
  set :deploy_to, "/srv/rails/dev-fedbus.feds.ca"
end

task :prod do
  server "www-app.fs.uwaterloo.ca", :web, :app
  role :db, "www-app.fs.uwaterloo.ca", :primary => true
  set :deploy_to, "/srv/rails/fedbus.feds.ca"
end

# If you are not using Passenger mod_rails comment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
