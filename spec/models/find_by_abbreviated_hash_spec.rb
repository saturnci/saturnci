require "rails_helper"

describe "finding by abbreviated hash" do
  let!(:job) { create(:job) }

  context "when the id matches" do
    it "finds the record" do
      extend ApplicationHelper
      found_job = Job.find_by_abbreviated_hash(abbreviated_hash(job))
      expect(job.id).to eq(found_job.id)
    end
  end

  context "when the id does not match" do
    it "does not find a record" do
      expect(Job.find_by_abbreviated_hash("blahblahblah")).to be nil
    end
  end

  context "when two ids match" do
    it "finds the record" do
      extend ApplicationHelper
      id_suffix = "-93cd-4cca-8d16-9f09b0b9d63a"
      matching_job = create(:job, id: abbreviated_hash(job.id) + id_suffix)

      expect {
        Job.find_by_abbreviated_hash(abbreviated_hash(job))
      }.to raise_error
    end
  end
end
