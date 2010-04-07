module Detonator

  # Modeled after the mongo-ruby-driver's cursor object.
  class QueryBuilder

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

    def limit(limit)
      @limit = limit.to_i

      self
    end

    def sort(*sorts)
      @sort = normalize_sorts(sorts)

      self
    end

    protected

      def finder_options
        {
          :selector => @selector,
          :skip => @skip,
          :limit => @limit,
          :sort => @sort,
        }
      end

      def normalize_sorts(sorts)
        returning([]) do |normalized_sorts|
          sorts.each do |sort|
            case sort
            when Array
              normalized_sorts << sort
            when Symbol, String
              normalized_sorts << [sort, :asc]
            end
          end
        end
      end

      def init_query_objects(options = {})
        @selector = options[:selector] || {}
        @skip     = options[:skip]
        @limit    = options[:limit]
        @sort     = options[:sort]
      end

      def merge_query_objects(options = {})
        return if options.blank?
        selector(options[:selector]) if options[:selector]
        skip(options[:skip]) if options[:skip]
        limit(options[:limit]) if options[:limit]
        sort(options[:sort]) if options[:sort]
      end

  end
end
