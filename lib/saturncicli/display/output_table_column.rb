module SaturnCICLI
  module Display
    class OutputTableColumn
      attr_accessor :attribute

      def initialize(attribute:, label:, formatter:, values:, spacer:)
        @attribute = attribute
        @label = label
        @values = values
        @formatter = formatter
        @spacer = spacer
      end

      def formatted_heading
        @label.ljust(ljust_length)
      end

      def formatted_value_justified(value)
        formatted_value(value).ljust(ljust_length)
      end

      def formatted_value(value)
        @formatter ? @formatter.call(value) : value
      end

      def ljust_length
        length_of_longest_item + @spacer.length
      end

      private

      def length_of_longest_item
        [length_of_longest_value, @label.length].max
      end

      def length_of_longest_value
        return 0 unless @values.any?
        @values.map { |v| formatted_value(v) }.map(&:length).max
      end
    end
  end
end
