require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => :tests

desc "Run Detonator tests"
Rake::TestTask.new(:tests) do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/*_test.rb']
end

require 'lib/detonator/version'

namespace :gem do
  desc "Install gem locally without ri and rdoc"
  task :install => [:build] do
    puts `gem install detonator-#{Detonator::VERSION}.gem --no-ri --no-rdoc`
  end

  desc "Install gem locally with ri and rdoc"
  task :full_install => [:build] do
    puts `gem install detonator-#{Detonator::VERSION}.gem --no-ri --no-rdoc`
  end

  desc "Build gemspec"
  task :build do
    puts `gem build detonator.gemspec`
  end
end
