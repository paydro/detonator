require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => :tests

desc "Run Detonator tests"
Rake::TestTask.new(:tests) do |t|
  t.libs << 'lib'
  t.test_files = FileList['test/*_test.rb']
end

namespace :gem do
  desc "Install gem locally"
  task :install => [:build] do
    `gem install detonator.gem`
  end

  desc "Build gemspec"
  task :build do
     `gem build detonator.gemspec`
  end
end
