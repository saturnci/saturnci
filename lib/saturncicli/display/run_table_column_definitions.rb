require_relative "column_definitions"

module SaturnCICLI
  module Display
    class RunTableColumnDefinitions < ColumnDefinitions
      define_columns do
        {
          "id" => {
            label: "ID",
            format: -> (hash) { Helpers.truncated_hash(hash) }
          },
          "created_at" => {
            label: "Created",
            format: -> (value) { Helpers.formatted_datetime(value) }
          },
          "status" => { label: "Test suite run status" },
          "test_suite_run_id" => {
            label: "Test suite run ID",
            format: -> (hash) { Helpers.truncated_hash(hash) }
          },
          "test_suite_run_commit_message" => {
            label: "Test suite run commit message",
            format: -> (value) { Helpers.truncate(Helpers.squish(value)) }
          },
        }
      end
    end
  end
end
