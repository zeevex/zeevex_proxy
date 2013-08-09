require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'


RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  PLATFORMS = %w{1.9.3-p448 2.0.0-p247 jruby-1.7.4 1.8.7-p374}

  desc "Run on three Rubies"
  task :platforms do
    # current = %x[rbenv version | awk '{print $1}']
    
    fail = false
    PLATFORMS.each do |version|
      puts "Switching to #{version}"
      Bundler.with_clean_env do
        system %{bash -c 'eval "$(rbenv init -)" && rbenv use #{version} && rbenv rehash && rbenv which ruby && ruby -v && rbenv exec bundle exec rake spec'}
      end
      if $?.exitstatus != 0
        fail = true
        break
      end
    end

    exit (fail ? 1 : 0)
  end

  task :platform_setup do
     PLATFORMS.each do |version|
      puts "Switching to #{version}"
      Bundler.with_clean_env do
        system %{bash -c 'eval "$(rbenv init -)" && rbenv use #{version} && rbenv rehash && gem install bundler && bundle install'}
      end
    end   
  end
end

task :default => 'spec'
