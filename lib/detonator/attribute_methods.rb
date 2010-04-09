module Detonator
  module AttributeMethods
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

      # Cast a given value to the specified type if value is not that type.
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
          type.new(value)
        end
      end

  end
end
