require File.join(File.dirname(__FILE__), 'test_helper')
require 'camera'
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

