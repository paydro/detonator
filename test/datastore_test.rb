require 'minitest/unit'
require 'minitest/spec'
require 'rubygems'
require 'ansi'

require 'test/unit'
require 'detonator'

class Camera < Detonator::MongoModel
  self.connection = Mongo::Connection.new.db("detonator_test")

  key :model, String
  key :num, Integer
  key :cost, Float
  key :bought_at, Time
  key :last_used_on, Date
end


class MiniTest::Unit
  include ANSI::Code

  PADDING_SIZE = 4

  def run(args = [])
    @verbose = true

    filter = if args.first =~ /^(-n|--name)$/ then
               args.shift
               arg = args.shift
               arg =~ /\/(.*)\// ? Regexp.new($1) : arg
             else
               /./ # anything - ^test_ already filtered by #tests
             end

    @@out.puts "Loaded suite #{$0.sub(/\.rb$/, '')}\nStarted"

    start = Time.now
    run_test_suites filter

    @@out.puts
    @@out.puts "Finished in #{'%.6f' % (Time.now - start)} seconds."

    @@out.puts

    @@out.print "%d tests, " % test_count
    @@out.print "%d assertions, " % assertion_count
    @@out.print red { "%d failures, " % failures }
    @@out.print yellow { "%d errors, " % errors }
    @@out.puts cyan { "%d skips" % skips}

    return failures + errors if @test_count > 0 # or return nil...
  end

  # Overwrite #run_test_suites so that it prints out reports
  # as errors are generated.
  def run_test_suites(filter = /./)
    @test_count, @assertion_count = 0, 0
    old_sync, @@out.sync = @@out.sync, true if @@out.respond_to? :sync=
    TestCase.test_suites.each do |suite|
      test_cases = suite.test_methods.grep(filter)
      if test_cases.size > 0
        @@out.print "\n#{suite}:\n"
      end

      test_cases.each do |test|
        inst = suite.new test
        inst._assertions = 0

        t = Time.now

        @broken = nil

        @@out.print(case inst.run(self)
                    when :pass
                      @broken = false
                      green { pad_with_size "PASS" }
                    when :error
                      @broken = true
                      yellow { pad_with_size "ERROR" }
                    when :fail
                      @broken = true
                      red { pad_with_size "FAIL" }
                    when :skip
                      @broken = false
                      cyan { pad_with_size "SKIP" }
                    end)


        @@out.print " #{test}"
        @@out.print " (%.2fs) " % (Time.now - t)

        if @broken
          @@out.puts

          report = @report.last
          @@out.puts pad(report[:message], 10)
          trace = MiniTest::filter_backtrace(report[:exception].backtrace).first
          @@out.print pad(trace, 10)

          @@out.puts
        end

        @@out.puts
        @test_count += 1
        @assertion_count += inst._assertions
      end
    end
    @@out.sync = old_sync if @@out.respond_to? :sync=
    [@test_count, @assertion_count]
  end

  def pad(str, size=PADDING_SIZE)
    " " * size + str
  end

  def pad_with_size(str)
    pad("%5s" % str)
  end

  # Overwrite #puke method so that is stores a hash
  # with :message and :exception keys.
  def puke(klass, meth, e)
    result = nil
    msg = case e
        when MiniTest::Skip
          @skips += 1
          result = :skip
          e.message
        when MiniTest::Assertion
          @failures += 1
          result = :fail
          e.message
        else
          @errors += 1
          result = :error
          "#{e.class}: #{e.message}\n"
        end

    @report << {:message => msg, :exception => e}
    result
  end


  class TestCase
    # Overwrite #run method so that is uses symbols
    # as return values rather than characters.
    def run(runner)
      result = :pass
      begin
        @passed = nil
        self.setup
        self.__send__ self.name
        @passed = true
      rescue Exception => e
        @passed = false
        result = runner.puke(self.class, self.name, e)
      ensure
        begin
          self.teardown
        rescue Exception => e
          result = runner.puke(self.class, self.name, e)
        end
      end
      result
    end
  end
end

class DetonatorTestCase < Test::Unit::TestCase
  def db
    @_db ||= Mongo::Connection.new.db("detonator_test")
  end
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

    fail
  end

  def test_skip
    skip
  end

  def test_save_casts_date_to_time_to_work_with_mongodb
    camera = Camera.new(:last_used_on => Date.today)
    assert camera.save

    doc = @collection.find({:_id => camera.id})
    assert_not_nil doc
    assert 1 == 2, "Assertion Message here!"
  end

  def test_id_set_on_save
    camera = Camera.new(:model => "Canon 1Ds")

    assert camera.save
    assert_not_nil camera.id
    flunk
  end

  def test_sawef
    assert_not_nil nil
  end

  def test_heef
    raise "This is so broken"
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
