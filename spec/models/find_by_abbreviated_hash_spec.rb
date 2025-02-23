require "rails_helper"

describe "finding by abbreviated hash" do
  let!(:run) { create(:run) }

  context "when the id matches" do
    it "finds the record" do
      extend ApplicationHelper
      found_run = Run.find_by_abbreviated_hash(abbreviated_hash(run))
      expect(run.id).to eq(found_run.id)
    end
  end

  context "when the id does not match" do
    it "does not find a record" do
      expect(Run.find_by_abbreviated_hash("blahblahblah")).to be nil
    end
  end

  context "when two ids match" do
    it "finds the record" do
      extend ApplicationHelper
      id_suffix = "-93cd-4cca-8d16-9f09b0b9d63a"
      matching_run = create(:run, id: abbreviated_hash(run.id) + id_suffix)

      expect {
        Run.find_by_abbreviated_hash(abbreviated_hash(run))
      }.to raise_error
    end
  end
end
