require "rails_helper"

describe "test suite run status", type: :model do
  before { Rails.cache.clear }

  context "test suite run is finished" do
    let!(:test_suite_run) { build(:build) }
    let!(:run_1) { build(:run, build: test_suite_run, order_index: 1) }
    let!(:run_2) { build(:run, build: test_suite_run, order_index: 2) }

    before do
      allow(run_1).to receive(:finished?).and_return(true)
      allow(run_2).to receive(:finished?).and_return(true)
      allow(test_suite_run).to receive(:runs).and_return([run_1, run_2])
    end

    context "status is set" do
      it "does not incur the expense of calculated_status" do
        test_suite_run.status
        expect(test_suite_run).not_to receive(:calculated_status)
        test_suite_run.status
      end
    end
  end

  context "no runs" do
    it "is 'Not Started'" do
      test_suite_run = build(:build)
      expect(test_suite_run.status).to eq("Not Started")
    end
  end

  context "some runs" do
    let!(:test_suite_run) { build(:build) }
    let!(:run_1) { build(:run, build: test_suite_run, order_index: 1) }
    let!(:run_2) { build(:run, build: test_suite_run, order_index: 2) }

    context "all runs have passed" do
      it "is passed" do
        allow(run_1).to receive(:status).and_return("Passed")
        allow(run_2).to receive(:status).and_return("Passed")
        allow(test_suite_run).to receive(:runs).and_return([run_1, run_2])

        expect(test_suite_run.status).to eq("Passed")
      end
    end

    context "any runs have failed" do
      it "is failed" do
        allow(run_1).to receive(:status).and_return("Passed")
        allow(run_2).to receive(:status).and_return("Failed")
        allow(test_suite_run).to receive(:runs).and_return([run_1, run_2])

        expect(test_suite_run.status).to eq("Failed")
      end
    end

    context "some runs are running, no runs are failed" do
      it "is running" do
        allow(run_1).to receive(:status).and_return("Passed")
        allow(run_2).to receive(:status).and_return("Running")
        allow(test_suite_run).to receive(:runs).and_return([run_1, run_2])

        expect(test_suite_run.status).to eq("Running")
      end
    end

    context "there are no runs" do
      it "is not started" do
        allow(test_suite_run).to receive(:runs).and_return([])

        expect(test_suite_run.status).to eq("Not Started")
      end
    end

    describe "caching" do
      context "cached_status matches calculated_status" do
        before do
          test_suite_run.update!(cached_status: "Passed")
          allow(run_1).to receive(:status).and_return("Passed")
          allow(run_2).to receive(:status).and_return("Passed")
          allow(test_suite_run).to receive(:runs).and_return([run_1, run_2])
        end

        it "does not update the test suite run" do
          expect(test_suite_run).not_to receive(:update!)
          test_suite_run.status
        end
      end
    end
  end
end
