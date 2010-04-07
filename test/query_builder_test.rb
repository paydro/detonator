require File.join(File.dirname(__FILE__), 'test_helper')
require 'camera'

class QueryBuilderTest < DetonatorTestCase
  def setup
    @relation = Detonator::QueryBuilder.new(Camera)
    @collection = Camera.collection

    @canon = Camera.create({:model => "Canon", :num => 1, :cost => 20.00})
    @nikon = Camera.create({:model => "Nikon", :num => 2, :cost => 30.00})
    @olympus = Camera.create({:model => "Olympus", :num => 3, :cost => 10.00})
    @pentax = Camera.create({:model => "Pentax", :num => 4, :cost => 50.00})
  end

  def teardown
    @collection.remove
  end

  def test_selector
    assert_relation @relation.selector(:model => "Canon", :num => 1)
    assert_equal [@canon], @relation.all
  end

  def test_selector_merges_criteria
    @relation.selector(:model => "Canon")
    @relation.selector(:num => 1)
    assert_equal [@canon], @relation.all
  end

  def test_selector_overwrites_criteria
    @relation.selector(:model => "Canon")
    @relation.selector(:model => "Nikon")
    assert_equal [@nikon], @relation.all
  end

  def test_sort_defaults_to_ascending_order
    @relation.sort(:num)
    assert_equal [@canon, @nikon, @olympus, @pentax], @relation.all
  end

  def test_sort_with_multiple_keys_defaults_keys_to_ascending
    @relation.sort(:cost, :num)
    assert_equal [@olympus, @canon, @nikon, @pentax], @relation.all
  end

  def test_sort_with_arrays
    @relation.sort([:num, :desc])
    assert_equal [@pentax, @olympus, @nikon, @canon], @relation.all
  end

  def test_limit_with_integer
    @relation.limit(1)

    # Mongo does not guarantee insert order, so we'll sort by :num
    @relation.sort(:num)

    assert_equal [@canon], @relation.all
  end

  def test_limit_with_string
    @relation.limit("1")

    # Mongo does not guarantee insert order, so we'll sort by :num
    @relation.sort(:num)

    assert_equal [@canon], @relation.all
  end

  def test_adding_criteria_does_not_query_db

  end

  def assert_relation(obj)
    assert Detonator::QueryBuilder === obj, "Expected object to be Detonator::QueryBuilder, instead was #{obj.class}"
  end
end

