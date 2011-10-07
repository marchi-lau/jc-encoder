$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require 'bundler/capistrano'
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, '1.9.2-p290'        # Or whatever env you want it to run in.

set :application, "jc-encoder"
# The URL to your applications repository
set :repository,  "git@github.com:marchi-lau/jc-encoder.git"
set :scm, :git
set :rails_env, "production" #added for delayed job  
ssh_options[:forward_agent] = true
default_run_options[:pty] = true
set :deploy_via, :remote_cache
# Require subversion to do an export instead of a checkout.
# The user you are using to deploy with (This user should have SSH access to your server)
set :user, "WMS"
set :scm_passphrase, "qweasdzxc"
set :rvm_type, :user  # Copy the exact line. I really mean :user here

# We want to deploy everything under your user, and we don't want to use sudo
set :use_sudo, false
# Where to deploy your application to.
set :deploy_to, "/Library/WebServer/Documents/#{application}/"
# ——————————– Server Definitions ——————————–
# Define the hostname of your server. If you have multiple servers for multiple purposes, we can define those below as well.
# We're assuming you're using a single server for your site, but if you have a seperate asset server or database server, you can specify that here.
role :app, "192.168.100.194","192.168.100.195"
role :web, "192.168.100.201"
role :db, "192.168.100.201", :primary => true

#role :db,  "your slave db-server here"
namespace :ssh do
  task :setup do
  servers = ["192.168.100.194", "192.168.100.194", "192.168.100.201"]
  system "ssh-keygen -t dsa"
  puts "Copying Public Keys to Server..."
  puts "Logging in with #{user}"
  servers.each do |server|
  system "scp '/Volumes/Macintosh HD/Users/Marchi/.ssh/id_dsa.pub' #{user}@#{server}:'~/'"
  run "mkdir -p ~/.ssh && chmod 700 ~/.ssh && touch -f ~/.ssh/authorized_keys2 && cat ~/id_dsa.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
#  scp ./racingfocus_20201231_01_chi.mov Administrator@118.142.104.200:"/Volumes/Videos/Dropbox/Dropbox\\ -\\ Default"
  end
  end
end
# Solve Bundle
# sudo ssh key to 600

namespace :deploy do
  # task :start do
  #   run "cd #{deploy_to}current && rails s -e production -d"
  # end
  # 
  # task :stop do
  #   run "killall -9 ruby"
  # end
  # 
  # task :restart do
  #   run "cd #{deploy_to}current && rails s -e production -d"
  #   run "killall -9 ruby"
  #   run "cd #{deploy_to}current && rails s -e production -d"
  # end
end

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end