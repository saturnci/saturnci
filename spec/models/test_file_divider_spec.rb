require "rails_helper"

describe TestFileDivider do
  describe "#divide" do
    context "when 10 files are divided among 3 tasks" do
      let!(:test_files) { (1..10).map { |i| "spec/file_#{i}_spec.rb" } }
      let!(:divider) { TestFileDivider.new(test_files:, task_count: 3) }

      it "assigns 4 files to task 1" do
        expect(divider.divide["1"].size).to eq(4)
      end

      it "assigns 3 files to task 2" do
        expect(divider.divide["2"].size).to eq(3)
      end

      it "assigns 3 files to task 3" do
        expect(divider.divide["3"].size).to eq(3)
      end
    end

    context "when 7 files are divided among 3 tasks" do
      let!(:test_files) { (1..7).map { |i| "spec/file_#{i}_spec.rb" } }
      let!(:divider) { TestFileDivider.new(test_files:, task_count: 3) }

      it "assigns 3 files to task 1" do
        expect(divider.divide["1"].size).to eq(3)
      end

      it "assigns 2 files to task 2" do
        expect(divider.divide["2"].size).to eq(2)
      end

      it "assigns 2 files to task 3" do
        expect(divider.divide["3"].size).to eq(2)
      end
    end

    context "when 3 files are divided among 3 tasks" do
      let!(:test_files) { (1..3).map { |i| "spec/file_#{i}_spec.rb" } }
      let!(:divider) { TestFileDivider.new(test_files:, task_count: 3) }

      it "assigns 1 file to task 1" do
        expect(divider.divide["1"].size).to eq(1)
      end

      it "assigns 1 file to task 2" do
        expect(divider.divide["2"].size).to eq(1)
      end

      it "assigns 1 file to task 3" do
        expect(divider.divide["3"].size).to eq(1)
      end
    end
  end
end
