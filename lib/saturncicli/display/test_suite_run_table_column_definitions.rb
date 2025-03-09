require_relative "column_definitions"

module SaturnCICLI
  module Display
    class TestSuiteRunTableColumnDefinitions < ColumnDefinitions
      define_columns do
        {
          "id" => {
            label: "Test suite run ID",
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
          "duration_formatted" => { label: "Duration" },
        }
      end
    end
  end
end
