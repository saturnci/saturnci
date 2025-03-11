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
          "name" => {
            label: "Name",
            format: -> (value) { Helpers.truncate(value) }
          },
          "cloud_id" => { label: "Cloud ID" }
        }
      end
    end
  end
end
