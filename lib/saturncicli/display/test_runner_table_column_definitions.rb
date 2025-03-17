require_relative "column_definitions"

module SaturnCICLI
  module Display
    class TestRunnerTableColumnDefinitions < ColumnDefinitions
      define_columns do
        {
          "id" => {
            label: "ID",
            format: -> (hash) { Helpers.truncated_hash(hash) }
          },
          "created_at" => {
            label: "Created At",
            format: -> (hash) { Helpers.formatted_datetime(hash) }
          },
          "name" => { label: "Name" },
          "status" => { label: "Status" },
          "run_id" => {
            label: "Run ID",
            format: -> (hash) { Helpers.truncated_hash(hash) }
          },
        }
      end
    end
  end
end
