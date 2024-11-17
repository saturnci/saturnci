require_relative "../../../lib/saturncicli/display/job_table_column_definitions"

describe "definitions" do
  describe "#define_columns" do
    let!(:definitions) do
      SaturnCICLI::Display::JobTableColumnDefinitions.new
    end

    it "sets the key of the first column to build_id" do
      expect(definitions.to_a[0][0]).to eq("id")
    end
  end
end
