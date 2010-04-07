require 'mongo'
require 'active_support/inflector'
require 'active_support/time'
require 'active_model'
require 'time'
require 'date'

module Detonator
  class Error < StandardError; end
  class DocumentNotFound < Error; end

  class Model
    extend ActiveModel::Naming
    extend ActiveModel::Callbacks
    include ActiveModel::Serialization
    include ActiveModel::Validations

    define_model_callbacks :save
    define_model_callbacks :create
    define_model_callbacks :update
    define_model_callbacks :destroy

    class << self

      # TODO: Find better way to initialize this.
      def connection=(conn)
        @@connection = conn
      end

      def connection
        @@connection
      end

      def collection=(coll)
        @collection = coll
      end

      def collection
        @collection ||= connection["#{self.to_s.tableize}"]
      end

      def create(attributes)
        doc = new(attributes)
        doc.save
        doc
      end

      def first(options = {})
        Relation.new(self).first(options)
      end

      def all(options = {})
        Relation.new(self).all(options)
      end

      def find(options = {})
        if String === options
          options = Mongo::ObjectID.from_string(options)
        end

        if Mongo::ObjectID === options
          record = first({:selector => {"_id" => options}})
          if record.nil?
            raise DocumentNotFound.new("Record not found with object id #{options}")
          end
          record
        else
          Relation.new(self).all(options)
        end
      end

      def raw_find(options = {})
        selector = options.delete(:selector) || {}
        records = collection.find(selector, options)

        returning([]) do |models|
          records.each do |record|
            models << init_from_record(record)
          end
          records.close
        end
      end

      protected

        def init_from_record(record)
          object = self.allocate
          object.send(:assign_attributes, record)
          object
        end

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

    end # End class methods


    # Instance Methods

    def to_model
      self
    end

    def new_record?
      @new_record ||= false
    end

    def destroyed?
      @destroyed ||= false
    end

    def to_param
      id.to_s
    end

    def ==(model)
      id == model.id
    end

    def initialize(attrs = {})
      @new_record = true
      assign_attributes(attrs)
    end

    def attributes
      @attributes["id"] = self.id unless @attributes.has_key?(:id)
      @attributes
    end

    def attributes=(new_attrs)
      assign_attributes(new_attrs)
    end

    def id
      @attributes["id"]
      # @id
    end

    def id=(id)
      @attributes["id"] = id
      # @id = id
    end

    def save
      _run_save_callbacks do
        document = self.attributes.dup
        document.each do |key, value|
          # Convert Date objects into Time objects since MongoDB cannot
          # use the Date object.
          if Date === value
            document[key] = value.to_time
          end
        end

        _id = document.delete("id")
        document["_id"] = _id unless new_record?

        self.id = collection.save(document)
        @new_record = false

        true
      end
    end

    def update_attributes(new_attributes)
      assign_attributes(new_attributes)
      save
    end

    def destroy
      collection.remove({:_id => id})
      @destroyed = true
      freeze

      self
    end

    protected

      def assign_attributes(new_attrs)
        @attributes ||= {}
        new_attrs.each do |attribute, value|
          if attribute == "_id"
            self.id = value
          else
            respond_to?(:"#{attribute}=") ? send("#{attribute}=", value) : raise("Undefined attribute: #{attribute}")
          end
        end
      end

      def connection
        self.class.connection
      end

      def collection
        self.class.collection
      end

      def cast_value(value, type)
        return value if type == value.class
        case
        when type == Integer
          value.to_i
        when type == Float
          value.to_f
        when type == String
          value.to_s
        when type == Date
          value.to_date
        when type == Time
          value.to_time
        else
          value
        end
      end

      def _update_timestamps
        time = Time.now
        if new_record? && self.created_at.blank?
          self.created_at = time
        end

        self.updated_at = time
      end

  end # End Model
end
