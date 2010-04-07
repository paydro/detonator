begin
  # Requirements
  require 'mocha'
  require 'timecop'
rescue LoadError
  puts "Please install these gems to run the tests:"
  puts "\n  gem install mocha"
  puts "\n  gem install timecop"
  exit 1
end

require 'detonator/pretty_minitest'
require 'test/unit'
require 'detonator'

# Add fixtures directory into load path
$:.unshift(File.join(File.dirname(__FILE__), "fixtures"))

class DetonatorTestCase < Test::Unit::TestCase
  def db
    @_db ||= Mongo::Connection.new.db("detonator_test")
  end
end
