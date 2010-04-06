require 'detonator/pretty_minitest'
require 'test/unit'
require 'detonator'

class DetonatorTestCase < Test::Unit::TestCase
  def db
    @_db ||= Mongo::Connection.new.db("detonator_test")
  end
end
