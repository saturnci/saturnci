module SaturnCICLI
  module Display
    class Row
      def initialize(values, columns)
        @values = values
        @columns = columns
      end

      def formatted
        formatted_values.join(@spacer).strip
      end

      private

      def formatted_values
        @columns.map { |c| c.formatted_value_justified(@values[c.attribute]) }
      end
    end
  end
end
