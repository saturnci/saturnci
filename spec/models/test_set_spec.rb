require "rails_helper"

describe TestSet do
  describe "#grouped" do
    context "when 10 files are grouped into 3" do
      let!(:test_files) { (1..10).map { |i| "spec/file_#{i}_spec.rb" } }
      let!(:test_set) { TestSet.new(test_files) }

      it "assigns 4 files to group 1" do
        expect(test_set.grouped(3)["1"].size).to eq(4)
      end

      it "assigns 3 files to group 2" do
        expect(test_set.grouped(3)["2"].size).to eq(3)
      end

      it "assigns 3 files to group 3" do
        expect(test_set.grouped(3)["3"].size).to eq(3)
      end
    end

    context "when 7 files are grouped into 3" do
      let!(:test_files) { (1..7).map { |i| "spec/file_#{i}_spec.rb" } }
      let!(:test_set) { TestSet.new(test_files) }

      it "assigns 3 files to group 1" do
        expect(test_set.grouped(3)["1"].size).to eq(3)
      end

      it "assigns 2 files to group 2" do
        expect(test_set.grouped(3)["2"].size).to eq(2)
      end

      it "assigns 2 files to group 3" do
        expect(test_set.grouped(3)["3"].size).to eq(2)
      end
    end

    context "when 3 files are grouped into 3" do
      let!(:test_files) { (1..3).map { |i| "spec/file_#{i}_spec.rb" } }
      let!(:test_set) { TestSet.new(test_files) }

      it "assigns 1 file to group 1" do
        expect(test_set.grouped(3)["1"].size).to eq(1)
      end

      it "assigns 1 file to group 2" do
        expect(test_set.grouped(3)["2"].size).to eq(1)
      end

      it "assigns 1 file to group 3" do
        expect(test_set.grouped(3)["3"].size).to eq(1)
      end
    end
  end
end
