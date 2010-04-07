module Detonator

  # Modeled after the mongo-ruby-driver's cursor object.
  class Relation

    def initialize(klass)
      @klass = klass

      init_query_objects
    end

    def first(options = {})
      return @records if loaded?
      merge_query_objects(options.merge(:limit => 1))
      to_a.first
    end

    # Returns collection
    def all(options = {})
      return @records if loaded?

      merge_query_objects(options)
      to_a
    end

    def size
      return @records.size if loaded?

      to_a.size
    end
    alias_method :count, :size

    def to_a
      @records = @klass.raw_find(finder_options)
    end

    def loaded?
      !@records.nil?
    end

    def selector(options = {})
      @selector.merge!(options)

      self
    end

    def fields(fields)
      @fields ||= []
      @fields.push(*fields).uniq!

      self
    end

    def limit(limit)
      @limit = limit

      self
    end

    def sort(sort)
      @sort = sort

      self
    end

    protected

      def finder_options
        {
          :selector => @selector,
          :fields => @fields,
          :skip => @skip,
          :limit => @limit,
          :sort => @sort,
        }
      end

      # TODO: Check option values are correct type
      def init_query_objects(options = {})
        @selector = options[:selector] || {}
        @fields   = options[:fields]
        @skip     = options[:skip]
        @limit    = options[:limit]
        @sort     = options[:sort]
      end

      def merge_query_objects(options = {})
        return if options.blank?
        selector(options[:selector]) if options[:selector]
        fields(options[:fields]) if options[:fields]
        skip(options[:skip]) if options[:skip]
        limit(options[:limit]) if options[:limit]
        sort(options[:sort]) if options[:sort]
      end

  end
end
