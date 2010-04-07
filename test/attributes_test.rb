require File.join(File.dirname(__FILE__), 'test_helper')
require 'camera'
class NewModelAttributeReadersTest < DetonatorTestCase

  def test_attr_string_readers
    camera = Camera.new(:model => "Canon Rebel XSi")
    assert_equal "Canon Rebel XSi", camera.model
  end

  def test_attr_integer_reader
    camera = Camera.new(:num => "4")
    assert_equal 4, camera.num

    camera = Camera.new(:num => 4)
    assert_equal 4, camera.num
  end

  def test_attr_float_reader
    camera = Camera.new(:cost => "14.01")
    assert_equal 14.01, camera.cost

    camera = Camera.new(:cost => 14.01)
    assert_equal 14.01, camera.cost
  end

  def test_attr_time_reader
    time = Time.now
    camera = Camera.new(:bought_at => time)
    assert_equal time, camera.bought_at
    assert_equal Time, camera.bought_at.class
  end

  def test_attr_date_reader
    date = Date.today
    camera = Camera.new(:last_used_on => date)
    assert_equal date, camera.last_used_on
    assert_equal Date, camera.last_used_on.class
  end
end


class ModelAttributeAssignmentTest < DetonatorTestCase

  def setup
    @camera = Camera.new
  end

  def test_attr_string_asignment
    @camera.model = "Canon Rebel XSi"
    assert_equal "Canon Rebel XSi", @camera.model
  end

  def test_attr_integer_asignment_with_string
    @camera.num = "4"
    assert_equal 4, @camera.num
  end

  def test_attr_integer_assignment_with_integer
    @camera.num = 5
    assert_equal 5, @camera.num
  end

  def test_attr_integer_assignment_with_float
    @camera.num = 5.1
    assert_equal 5, @camera.num
  end

  def test_attr_float_asignment_with_string
    @camera.cost = "14.01"
    assert_equal 14.01, @camera.cost
  end

  def test_attr_float_assignment_with_float
    @camera.cost = 0.99
    assert_equal 0.99, @camera.cost
  end

  def test_attr_float_assignment_with_integer
    @camera.cost = 1
    assert_equal 1.0, @camera.cost
  end

  def test_attr_time_asignment
    time = Time.now
    @camera.bought_at = time
    assert_equal time, @camera.bought_at
    assert_equal Time, @camera.bought_at.class
  end

  def test_attr_date_asignment
    date = Date.today
    @camera.last_used_on = date
    assert_equal date, @camera.last_used_on
    assert_equal Date, @camera.last_used_on.class
  end

  def test_missing_attr_assignment
    assert_raise NoMethodError do
      @camera.something_bogus = "BOOM!"
    end
  end

end

class DetonatorMongoModelAttributesTest < DetonatorTestCase
  def test_attributes_asigned_via_symbols_returns_keys_as_strings
    camera = Camera.new(:model => "Canon 5D", :cost => 19.99)
    attrs = {"id" => nil, "model" => "Canon 5D", "cost" => 19.99}
    assert_equal attrs, camera.attributes
  end
end


