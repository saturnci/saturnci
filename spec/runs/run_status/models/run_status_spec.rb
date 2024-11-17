require "rails_helper"

RSpec.describe Job, type: :model do
  describe "#status" do
    context "exit code is nil" do
      it "returns 'Running'" do
        job = create(:job)
        expect(job.status).to eq("Running")
      end
    end

    context "exit code is 0" do
      it "returns 'Passed'" do
        job = create(:job, exit_code: 0)
        expect(job.status).to eq("Passed")
      end
    end

    context "exit code is not 0" do
      it "returns 'Failed'" do
        job = create(:job, exit_code: 1)
        expect(job.status).to eq("Failed")
      end
    end
  end

  def success
    <<~RESULTS
example_id                                                 | status | run_time        |
---------------------------------------------------------- | ------ | --------------- |
./spec/models/github_token_spec.rb[1:2:1]                  | passed | 0.00288 seconds |
./spec/rebuilds_spec.rb[1:1:1]                             | passed | 0.04704 seconds |
./spec/sign_up_spec.rb[1:1:1]                              | passed | 0.1331 seconds  |
./spec/test_spec.rb[1:1]                                   | passed | 0.00798 seconds |
    RESULTS
  end

  def failure
    <<~RESULTS
example_id                                                 | status | run_time        |
---------------------------------------------------------- | ------ | --------------- |
./spec/models/github_token_spec.rb[1:2:1]                  | passed | 0.00288 seconds |
./spec/rebuilds_spec.rb[1:1:1]                             | passed | 0.04704 seconds |
./spec/sign_up_spec.rb[1:1:1]                              | passed | 0.1331 seconds  |
./spec/test_spec.rb[1:1]                                   | failed | 0.00798 seconds |
    RESULTS
  end
end
