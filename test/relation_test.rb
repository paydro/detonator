require File.join(File.dirname(__FILE__), 'test_helper')
require 'camera'

class RelationTest < DetonatorTestCase
  def setup
    @relation = Detonator::Relation.new(Camera)
    @collection = Camera.collection
  end

  def teardown
    @collection.remove
  end

  def test_selector
    Camera.expects(:raw_find).with({:selector => {:model => "Canon"}, :fields => nil, :skip => nil, :limit => nil, :sort => nil}).returns([])
    relation = @relation.selector(:model => "Canon")
    assert_relation relation
    @relation.all
  end

  def test_multi_call_to_selector_merges
    flunk
  end

  def assert_relation(obj)
    assert Detonator::Relation === obj, "Expected object to be Detonator::Relation, instead was #{obj.class}"
  end
end

