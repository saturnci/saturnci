require_relative "helpers"
require_relative "row"
require_relative "column"
require_relative "column_definition"

module SaturnCICLI
  module Display
    class Table
      SPACER = "  "

      def initialize(items:, options: {}, resource_name:)
        @items = items
        @options = options
        @column_definitions = ColumnDefinition.find(resource_name)
      end

      def to_s
        [header, formatted_items].join("\n")
      end

      private

      def header
        columns.map(&:formatted_heading).join.strip
      end

      def formatted_items
        @items.map do |item|
          Row.new(item, columns).formatted
        end
      end

      def columns
        included_column_definitions.map do |attribute, definition|
          Column.new(
            attribute: attribute,
            label: definition[:label],
            formatter: definition[:format],
            values: @items.map { |item| item[attribute] },
            spacer: SPACER
          )
        end
      end

      def included_column_definitions
        @column_definitions.select do |attribute, _|
          @options[:columns].nil? || @options[:columns].include?(attribute)
        end
      end
    end
  end
end
