require "rails_helper"

RSpec.describe Run, type: :model do
  describe "#status" do
    context "exit code is nil" do
      it "returns 'Running'" do
        run = create(:run)
        expect(run.status).to eq("Running")
      end
    end

    context "exit code is 0" do
      it "returns 'Passed'" do
        run = create(:run, exit_code: 0)
        expect(run.status).to eq("Passed")
      end
    end

    context "exit code is not 0" do
      it "returns 'Failed'" do
        run = create(:run, exit_code: 1)
        expect(run.status).to eq("Failed")
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
