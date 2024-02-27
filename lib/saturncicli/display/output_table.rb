require_relative "output_table_row"
require_relative "output_table_column"

module SaturnCICLI
  module Display
    class OutputTable
      SPACER = "  "

      HEADING_DEFINITIONS = {
        "branch_name" => { label: "Branch" },

        "commit_hash" => {
          label: "Commit",
          format: -> (value) { value[0..7] }
        },

        "commit_message" => {
          label: "Commit message",
          format: -> (value) { CLIHelpers.truncate(CLIHelpers.squish(value)) }
        }
      }

      def initialize(items)
        @items = items
      end

      def to_s
        [header, formatted_items].join("\n")
      end

      private

      def header
        columns.map(&:formatted_heading).join.strip
      end

      def columns
        HEADING_DEFINITIONS.map do |attribute, definition|
          OutputTableColumn.new(
            attribute: attribute,
            label: definition[:label],
            formatter: definition[:format],
            values: @items.map { |item| item[attribute] },
            spacer: SPACER
          )
        end
      end

      def formatted_items
        @items.map do |item|
          OutputTableRow.new(item, columns).formatted
        end
      end
    end
  end
end
