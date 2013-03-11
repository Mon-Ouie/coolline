$LOAD_PATH.unshift File.expand_path(File.join("lib", File.dirname(__FILE__)))
require 'coolline/version'

task :test do
  ruby "test/run_all.rb"
end

task :build do
  sh "gem build .gemspec"
end

task :release => :build do
  sh "gem push coolline-#{Coolline::Version}.gem"
end

task :install => :build do
  sh "gem install coolline-#{Coolline::Version}.gem"
end
