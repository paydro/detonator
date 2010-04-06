require File.join(File.dirname(__FILE__), 'test_helper')

class ActiveModelComplianceTest < Test::Unit::TestCase
  include ActiveModel::Lint::Tests

  class CompliantModel < Detonator::Model
  end

  def setup
    @model = CompliantModel.new
  end

end
