require File.join(File.dirname(__FILE__), 'test_helper')
require 'camera'

class FinderTest < DetonatorTestCase

  def setup
    @collection = Camera.collection
  end

  def teardown
    @collection.remove
  end

  def test_find_first
    test_record_id = @collection.insert({
      :model => "Canon 50D",
      :num => 1,
      :cost => 1_000.99,
      :bought_at => Time.now,
      :last_used_on => Time.now
    })

    Camera.collection = @collection
    camera = Camera.first
    assert_equal test_record_id, camera.id
  end

  def test_date_casting
    test_record_id = @collection.insert({:last_used_on => Time.now})

    camera = Camera.first

    assert_equal Date, camera.last_used_on.class
  end

  def test_find
    record_id = @collection.insert({:model => "Canon 70D"})

    cameras = Camera.find(:selector => {"model" => "Canon 70D"})
    assert_equal record_id, cameras.first.id
  end

  def test_find_is_not_destroyed
    record_id = @collection.insert({:model => "Canon 70D"})
    camera = Camera.find(record_id)
    assert_equal false, camera.destroyed?
  end

  def test_find_with_symbols
    record_id = @collection.insert({:model => "Canon 70D"})

    cameras = Camera.find(:selector => {:model => "Canon 70D"})
    assert_equal record_id, cameras.first.id
  end

  def test_find_many
    @collection.insert({:model => "Canon 70D"})
    @collection.insert({:model => "Canon 50D"})
    @collection.insert({:model => "Canon 40D"})

    cameras = Camera.find(:sort => ["model", :desc])
    assert_equal "Canon 70D", cameras[0].model
    assert_equal "Canon 50D", cameras[1].model
    assert_equal "Canon 40D", cameras[2].model
  end

  def test_all_convenience_method
    @collection.insert({:model => "Canon 50D"})
    @collection.insert({:model => "Canon 70D"})

    cameras = Camera.all
    assert_equal 2, cameras.size
    assert "Canon 50D", cameras[0].model
    assert "Canon 70D", cameras[1].model
  end

  def test_find_with_id_string_returns
    record_id = @collection.insert(:model => "Canon 70D")

    camera = Camera.find(record_id.to_s)
    assert "Canon 70D", camera.model
  end

  def test_find_with_id_ObjectID
    record_id = @collection.insert({:model => "Canon 70D"})

    camera = Camera.find(record_id)
    assert "Canon 70D", camera.model
  end

  def test_find_is_not_new_record
    record_id = @collection.insert({:model => "Canon 70D"})

    camera = Camera.find(record_id)
    assert_equal false, camera.new_record?
  end

  def test_find_sets_id
    record_id = @collection.insert({:model => "Canon 70D"})
    camera = Camera.find(:selector => {:model => "Canon 70D"}).first
    assert_equal record_id, camera.id
  end

  def test_raw_find
    @collection.remove
    5.times {|i| @collection.insert({:model => "Canon #{i}"}) }

    records = Camera.raw_find(:limit => 2, :skip => 1, :sort => [["model", :asc]])

    assert_equal ["Canon 1", "Canon 2"], records.collect(&:model)
  end

  def test_find_with_nonexisting_object_id_raises_record_not_found
    id = @collection.insert({:model => "Delete me"})
    @collection.remove({"_id" => id})
    assert_raise Detonator::DocumentNotFound do
      Camera.find(id)
    end
  end

end
