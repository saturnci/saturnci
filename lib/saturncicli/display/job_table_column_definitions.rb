require_relative "column_definitions"

module SaturnCICLI
  module Display
    class JobTableColumnDefinitions < ColumnDefinitions
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
          "status" => { label: "Build status" },
          "build_id" => {
            label: "Build ID",
            format: -> (hash) { Helpers.truncated_hash(hash) }
          },
          "build_commit_message" => {
            label: "Build commit message",
            format: -> (value) { Helpers.truncate(Helpers.squish(value)) }
          },
        }
      end
    end
  end
end
