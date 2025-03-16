require_relative "../../lib/saturncicli/arguments"

describe SaturnCICLI::Arguments do
  context "--run abc123" do
    it "works" do
      argv = %w(--run abc123)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:run, "abc123"])
    end
  end

  context "--test-runner abc123 delete" do
    it "works" do
      argv = %w(--test-runner abc123 delete)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:delete_test_runner, "abc123"])
    end
  end
end
