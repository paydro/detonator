require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

task :default => ["tests:all"]

namespace :tests do
  desc "Run Detonator tests"
  Rake::TestTask.new(:all) do |t|
    t.libs << 'lib'
    t.test_files = FileList['test/*_test.rb']
  end
end
