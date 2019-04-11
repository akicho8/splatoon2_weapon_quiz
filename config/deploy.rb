# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, Pathname(__dir__).dirname.basename.to_s
set :repo_url, "git@github.com:akicho8/#{fetch(:application)}.git"
# set :repo_url, "file://#{Pathname(__dir__).dirname}"
set :deploy_to, "/var/www/#{fetch(:application)}_#{fetch(:stage)}"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 1

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

if ENV["RUN_REMOTE"]
  desc 'npm run build'
  after 'deploy:updated', :build do
    on roles(:all) do
      within release_path do
        execute :yarn
        execute :yarn, 'run', 'build'
      end
    end
  end
else
  desc "ローカルで npm run build してデプロイ先にコピーする"
  after "deploy:updated", :local_build_and_copy_to_remote do
    # tmpdir = "/tmp/__repository_#{fetch(:application)}_#{fetch(:stage)}"
    # system "rm -fr #{tmpdir}"
    # system "git clone #{fetch(:repo_url)} --branch #{fetch(:branch)} #{tmpdir}"
    # system "cd #{tmpdir} && yarn"
    # system "cd #{tmpdir} && yarn run generate"
    # roles(:web).each do |e|
    #   system "cd #{tmpdir} && rsync -au --delete -e ssh dist #{e.user}@#{e.hostname}:#{release_path}"
    # end
    # # system "rm -fr #{tmpdir}"

    Rake::Task[:up].invoke
  end
end

# cap production cp
desc "開発ディレクトリの dist を転送"
task :up do
  system "yarn run generate"
  roles(:web).each do |e|
    system "rsync -au --delete -e ssh dist #{e.user}@#{e.hostname}:#{release_path}"
  end
end
