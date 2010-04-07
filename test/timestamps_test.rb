require File.join(File.dirname(__FILE__), 'test_helper')
require 'camera'
class TimestampTest < DetonatorTestCase
  def teardown
    Timecop.return
  end

  def test_created_at_exists
    camera = Camera.new(:model => "Canon 5D")
    assert_equal nil, camera.created_at
  end

  def test_created_at_key_exists
    camera = Camera.new(:model => "Canon 5D")
    assert_equal nil, camera.created_at
  end

  def test_updated_at_key_exists
    camera = Camera.new(:model => "Canon 5D")
    assert_equal nil, camera.updated_at
  end

  def test_creating_object_sets_updated_at
    camera = Camera.new(:model => "Canon 5D")
    assert_equal nil, camera.updated_at

    mock_time = Time.now
    Timecop.freeze(mock_time)

    camera.save
    assert_equal mock_time, camera.updated_at
  end

  def test_creating_object_sets_created_at
    camera = Camera.new(:model => "Canon 5D")
    assert_equal nil, camera.created_at

    mock_time = Time.now
    Timecop.freeze(mock_time)

    camera.save
    assert_equal mock_time, camera.created_at
  end

  def test_saving_object_sets_updated_at
    camera = Camera.new(:model => "Canon 5D")
    camera.save
    current_obj_time = camera.updated_at

    # Mock time to 10 minutes from now
    mock_time = Time.now + 600
    Timecop.freeze(mock_time)

    camera.model = "Canon 5D Mark II"
    camera.save
    assert_equal mock_time, camera.updated_at
  end

  def test_saving_object_does_not_update_created_at
    camera = Camera.new(:model => "Canon 5D")
    camera.save
    current_obj_time = camera.created_at

    # Mock time so that it's not the same as now
    mock_time = Time.now + 600
    Timecop.freeze(mock_time)

    camera.model = "Canon 5D Mark II"
    camera.save
    assert_equal current_obj_time, camera.created_at
  end

  def test_saving_object_with_created_at_keeps_value
    time = Time.now
    camera = Camera.new(:model => "Canon 5D", :created_at => time)

    Timecop.freeze(Time.now + 600)
    camera.save

    assert_equal time, camera.created_at
  end

  def test_saving_object_with_updated_at_does_not_keep_value
    time = Time.now
    camera = Camera.new(:model => "Canon 5D", :updated_at => time)

    Timecop.freeze(Time.now + 600)
    camera.save

    assert_not_equal time, camera.updated_at
  end
end
