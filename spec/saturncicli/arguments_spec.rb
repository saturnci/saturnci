require_relative "../../lib/saturncicli/arguments"

describe SaturnCICLI::Arguments do
  context "run abc123" do
    it "calls run" do
      argv = %w(run abc123)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:run, "abc123"])
    end
  end

  context "test-runners delete abc123 def456" do
    it "calls delete_test_runner" do
      argv = %w(test-runners delete abc123 def456)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:delete_test_runner, ["abc123", "def456"]])
    end
  end

  context "test-runners delete --all" do
    it "calls delete_all_test_runners" do
      argv = %w(test-runners delete --all)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:delete_all_test_runners])
    end
  end

  context "test-runners" do
    it "calls test_runners" do
      argv = %w(test-runners)
      arguments = SaturnCICLI::Arguments.new(argv)
      expect(arguments.command).to eq([:test_runners])
    end
  end
end
