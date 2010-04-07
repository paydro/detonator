require File.join(File.dirname(__FILE__), 'test_helper')

class SaveCallbackTest < DetonatorTestCase

  class BeforeSaveCallbackModel < Detonator::Model
    self.connection = Mongo::Connection.new.db("detonator_test")
    key :name, String


    attr_accessor :test_me
    before_save :set_test_me
    def set_test_me
      self.test_me = "set before save"
    end
  end

  class AfterSaveCallbackModel < Detonator::Model
    self.connection = Mongo::Connection.new.db("detonator_test")
    key :name, String

    attr_accessor :test_me
    after_save :set_test_me

    def set_test_me
      self.test_me = "set after save"
    end
  end

  def test_before_save
    model = BeforeSaveCallbackModel.new
    assert_equal nil, model.test_me
    model.save
    assert_equal "set before save", model.test_me
  end

  def test_after_save
    model = AfterSaveCallbackModel.new
    assert_equal nil, model.test_me
    model.save
    assert_equal "set after save", model.test_me
  end
end

