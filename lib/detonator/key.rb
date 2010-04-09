module Detonator
  module Key

    # Key creation methods
    def key(name, type)
      create_reader(name, type)
      create_writer(name, type)
    end

    def timestamps
      %w[created_at updated_at].each do |name|
        key name, Time
      end

      before_save :_update_timestamps
    end

    def create_reader(name, type)
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}
          attributes["#{name}"]
        end
      RUBY
    end

    def create_writer(name, type)
      class_eval <<-RUBY, __FILE__, __LINE__
        def #{name}=(value)
          self.attributes["#{name}"] = cast_value(value, #{type})
        end
      RUBY
    end

  end

end
