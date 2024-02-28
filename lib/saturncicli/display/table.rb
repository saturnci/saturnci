require_relative "helpers"
require_relative "row"
require_relative "column"

module SaturnCICLI
  module Display
    class Table
      SPACER = "  "

      COLUMN_DEFINITIONS = {
        "id" => {
          label: "Build ID",
          format: -> (hash) { Helpers.truncated_hash(hash) }
        },

        "created_at" => {
          label: "Created",
          format: -> (value) { Helpers.formatted_datetime(value) }
        },

        "branch_name" => { label: "Branch" },

        "commit_hash" => {
          label: "Commit",
          format: -> (hash) { Helpers.truncated_hash(hash) }
        },

        "commit_message" => {
          label: "Commit message",
          format: -> (value) { Helpers.truncate(Helpers.squish(value)) }
        },

        "status" => { label: "Status" },
      }

      def initialize(items, options = {})
        @items = items
        @options = options
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
        COLUMN_DEFINITIONS.select do |attribute, _|
          @options[:columns].nil? || @options[:columns].include?(attribute)
        end
      end
    end
  end
end
