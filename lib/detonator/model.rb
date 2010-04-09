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

    extend Key
    include AttributeMethods
    include ActiveModelCompliance

    # ActiveModel
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
        QueryBuilder.new(self).first(options)
      end

      def all(options = {})
        QueryBuilder.new(self).all(options)
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
          QueryBuilder.new(self).all(options)
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


    end # End class methods


    # Instance Methods

    def ==(model)
      id == model.id
    end

    # Driver related methods

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
    end

    def id=(id)
      @attributes["id"] = id
    end

    def save
      _run_save_callbacks do
        document = self.attributes.dup
        attributes.each do |key, value|
          # Convert Date objects into Time objects since MongoDB cannot
          # use the Date object.
          if Date === value
            document[key] = value.to_time
          elsif !value.nil? && !value.is_a?(Mongo::ObjectID) && not_primitive?(value)
            document[key] = value.to_doc
          end
        end

        _id = document.delete("id")
        document["_id"] = _id unless new_record?

        self.id = collection.save(document)
        @new_record = false

        true
      end
    end

    def not_primitive?(value)
      !(value.is_a?(String) || value.is_a?(Integer) || value.is_a?(Float) || value.is_a?(Time))
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

      def connection
        self.class.connection
      end

      def collection
        self.class.collection
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
