require File.join(File.dirname(__FILE__), 'test_helper')

class Camera < Detonator::MongoModel
  self.connection = Mongo::Connection.new.db("detonator_test")

  key :model, String
  key :num, Integer
  key :cost, Float
  key :bought_at, Time
  key :last_used_on, Date
end


class SaveModelTest < DetonatorTestCase

  def setup
    @collection = Camera.collection
  end

  def teardown
    @collection.remove
  end

  def test_save
    size_before = @collection.count
    camera = Camera.new(:model => "Test")
    assert camera.save
    assert_equal size_before + 1, @collection.count
    record = @collection.find_one(camera.id)
    assert_equal "Test", record["model"]
  end

  def test_save_casts_date_to_time_to_work_with_mongodb
    camera = Camera.new(:last_used_on => Date.today)
    assert camera.save

    doc = @collection.find({:_id => camera.id})
    assert_not_nil doc
  end

  def test_id_set_on_save
    camera = Camera.new(:model => "Canon 1Ds")

    assert camera.save
    assert_not_nil camera.id
  end
end

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

    cameras = Camera.find("model" => "Canon 70D")
    assert_equal record_id, cameras.first.id
  end

  def test_find_is_not_new_record
    record_id = @collection.insert({:model => "Canon 70D"})

    camera = Camera.find(record_id)
    assert_equal false, camera.new_record?
  end

  def test_find_is_not_destroyed
    record_id = @collection.insert({:model => "Canon 70D"})
    camera = Camera.find(record_id)
    assert_equal false, camera.destroyed?
  end

  def test_find_with_symbols
    record_id = @collection.insert({:model => "Canon 70D"})

    cameras = Camera.find(:model => "Canon 70D")
    assert_equal record_id, cameras.first.id
  end

  def test_find_many
    @collection.insert({:model => "Canon 70D"})
    @collection.insert({:model => "Canon 50D"})
    @collection.insert({:model => "Canon 40D"})

    cameras = Camera.find
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


end

class UpdateTest < DetonatorTestCase

  def setup
    @collection = Camera.collection
  end

  def teardown
    @collection.remove
  end

  def test_save_existing_object
    id = @collection.insert(:model => "Canon Rebel XSi")
    camera = Camera.find(id.to_s)
    assert_equal "Canon Rebel XSi", camera.model
    assert_equal id, camera.id

    camera.model = "Canon Rebel XT"
    assert camera.save

    record = @collection.find_one("model" => "Canon Rebel XT")
    assert_equal "Canon Rebel XT", camera.model
    assert_equal "Canon Rebel XT", record["model"]
  end

  def test_update_attributes_updates_model_attributes
    id = @collection.insert(:model => "Canon Rebel XSi")
    camera = Camera.find(id.to_s)

    assert camera.update_attributes(
      :model => "Canon Rebel XSi (old)",
      :cost => 19.99
    )

    assert_equal "Canon Rebel XSi (old)", camera.model
    assert_equal 19.99, camera.cost
    assert_equal id, camera.id
  end

  def test_update_attributes_updates_db_record
    id = @collection.insert(:model => "Canon Rebel XSi")
    camera = Camera.find(id.to_s)

    assert camera.update_attributes(
      :model => "Canon Rebel XSi (old)",
      :cost => 19.99
    )

    record = @collection.find_one(id)
    assert_equal "Canon Rebel XSi (old)", record["model"]
    assert_equal 19.99, record["cost"]
  end

end

class DestroyTest < DetonatorTestCase

  def setup
    @collection = Camera.collection

    id = @collection.insert(:model => "Canon 1D")
    @record_count = @collection.count

    @camera = Camera.find(id.to_s)
  end

  def teardown
    @collection.remove
  end

  def test_destroy_existing_object
    @camera.destroy
    assert_equal @record_count - 1, @collection.count
  end

  def test_destroy_freezes_object
    @camera.destroy

    assert @camera.frozen?
  end

  def test_destroy_object_destroyed?
    @camera.destroy
    assert @camera.destroyed?
  end
end

