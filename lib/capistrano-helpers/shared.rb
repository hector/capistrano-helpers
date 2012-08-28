require File.dirname(__FILE__) + '/../capistrano-helpers' if ! defined?(CapistranoHelpers)

CapistranoHelpers.with_configuration do
 
  namespace :deploy do
    desc 'Replace named files with a symlink to their counterparts in shared/'
    task :symlink_shared do
      if !exists?(:shared)
        abort 'You must specify which files to symlink using the "set :shared" command.'
      end
      shared.each do |path|
        if release_path.nil? || release_path.empty? || path.nil? || path.empty?
          raise "Release path or path are nil!"
        end
        run "rm -rf #{release_path}/#{path} && ln -nfs #{shared_path}/#{path} #{release_path}/#{path}"
      end
    end
    
    desc '[internal] Create the defined shared directories'
    task :create_shared_dirs do
      if !exists?(:shared)
        abort 'You must specify which files to symlink using the "set :shared" command.'
      end
      shared.each do |path|
        shared_dir = File.join(shared_path, path)
        run "#{try_sudo} mkdir -p #{shared_dir}"
        run "#{try_sudo} chmod o-rwx #{shared_dir}"
      end
    end    
  end

  before "deploy:finalize_update", "deploy:symlink_shared"
  after "deploy:setup", "deploy:create_shared_dirs"
end