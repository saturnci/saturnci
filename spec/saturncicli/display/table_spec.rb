require_relative "../../../lib/saturncicli/display/table"

describe "table" do
  context "nil value" do
    let!(:table) do
      items = [
        {
          "commit_hash" => "7f8c8132",
          "status" => nil
        },
      ]

      SaturnCICLI::Display::Table.new(
        resource_name: :test_suite_run,
        items: items,
        options: {
          columns: %w[commit_hash status]
        }
      )
    end

    it "shows nothing" do
      expected_output = <<~OUTPUT
      Commit    Status
      7f8c8132
      OUTPUT

      expect(table.to_s).to eq(expected_output.strip)
    end
  end

  context "short commit message" do
    let!(:table) do
      items = [
        {
          "branch_name" => "saturnci-client",
          "commit_hash" => "7f8c8132",
          "commit_message" => "Short commit message"
        },
      ]

      SaturnCICLI::Display::Table.new(
        resource_name: :test_suite_run,
        items: items,
        options: {
          columns: %w[branch_name commit_hash commit_message]
        }
      )
    end

    it "does not get truncated" do
      expected_output = <<~OUTPUT
      Branch           Commit    Commit message
      saturnci-client  7f8c8132  Short commit message
      OUTPUT

      expect(table.to_s).to eq(expected_output.strip)
    end
  end

  context "long commit message" do
    let!(:table) do
      long_commit_message = <<~TEXT
      This is an extremely long commit message which spans multiple lines
      and is entirely too verbose to be reasonably shown as a value in a
      line on a table.
      TEXT

      items = [
        {
          "branch_name" => "saturnci-client",
          "commit_hash" => "7f8c8132",
          "commit_message" => long_commit_message
        },
      ]

      SaturnCICLI::Display::Table.new(
        resource_name: :test_suite_run,
        items: items,
        options: {
          columns: %w[branch_name commit_hash commit_message]
        }
      )
    end

    it "gets truncated" do
      expected_output = <<~OUTPUT
      Branch           Commit    Commit message
      saturnci-client  7f8c8132  This is an extremely...
      OUTPUT

      expect(table.to_s).to eq(expected_output.strip)
    end
  end

  context "commit message with newlines" do
    let!(:table) do
      commit_message = <<~TEXT
Squashed commit of th...
                                                                   
commit...
      TEXT

      items = [
        {
          "branch_name" => "main",
          "commit_hash" => "2126d876",
          "commit_message" => commit_message
        },
      ]

      SaturnCICLI::Display::Table.new(
        resource_name: :test_suite_run,
        items: items,
        options: {
          columns: %w[branch_name commit_hash commit_message]
        }
      )
    end

    it "gets the newlines compressed" do
      expected_output = <<~OUTPUT
      Branch  Commit    Commit message
      main    2126d876  Squashed commit of th...
      OUTPUT

      expect(table.to_s).to eq(expected_output.strip)
    end
  end
end
