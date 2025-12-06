require "rails_helper"

describe "test suite run status_with_counts", type: :model do
  let!(:test_suite_run) { create(:build, dry_run_example_count: 100) }

  context "status is Passed" do
    before do
      create(:run, :passed, build: test_suite_run, order_index: 1)
    end

    it "displays Passed with total count" do
      expect(test_suite_run.status_with_counts).to eq("Passed (100)")
    end
  end

  context "status is Failed" do
    before do
      run = create(:run, :failed, build: test_suite_run, order_index: 1)
      create(:test_case_run, task: run, status: :passed)
      create(:test_case_run, task: run, status: :failed)
      create(:test_case_run, task: run, status: :failed)
    end

    it "displays Failed with failure count and total count" do
      expect(test_suite_run.status_with_counts).to eq("Failed (2/100)")
    end
  end

  context "status is Running" do
    before do
      create(:run, build: test_suite_run, order_index: 1)
    end

    it "displays Running without counts" do
      expect(test_suite_run.status_with_counts).to eq("Running")
    end
  end

  context "status is Not Started" do
    it "displays Not Started without counts" do
      expect(test_suite_run.status_with_counts).to eq("Not Started")
    end
  end
end

describe "test suite run status", type: :model do
  before { Rails.cache.clear }

  context "test suite run is finished" do
    let!(:test_suite_run) { build(:build) }
    let!(:run_1) { build(:run, build: test_suite_run, order_index: 1) }
    let!(:run_2) { build(:run, build: test_suite_run, order_index: 2) }

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
    let!(:test_suite_run) { create(:build) }

    context "all runs have passed" do
      let!(:run_1) { create(:run, :passed, build: test_suite_run, order_index: 1) }
      let!(:run_2) { create(:run, :passed, build: test_suite_run, order_index: 2) }

      it "is passed" do
        expect(test_suite_run.status).to eq("Passed")
      end
    end

    context "any runs have failed" do
      let!(:run_1) { create(:run, :passed, build: test_suite_run, order_index: 1) }
      let!(:run_2) { create(:run, :failed, build: test_suite_run, order_index: 2) }

      it "is failed" do
        expect(test_suite_run.status).to eq("Failed")
      end
    end

    context "some runs are running, no runs are failed" do
      let!(:run_1) { create(:run, build: test_suite_run, order_index: 1) }
      let!(:run_2) { create(:run, :failed, build: test_suite_run, order_index: 2) }

      it "is running" do
        expect(test_suite_run.status).to eq("Running")
      end
    end

    context "there are no runs" do
      it "is not started" do
        allow(test_suite_run).to receive(:runs).and_return(Run.none)

        expect(test_suite_run.status).to eq("Not Started")
      end
    end

    describe "database caching" do
      context "cached_status matches calculated_status" do
        let!(:run_1) { create(:run, :passed, build: test_suite_run, order_index: 1) }
        let!(:run_2) { create(:run, :passed, build: test_suite_run, order_index: 2) }

        before do
          test_suite_run.update!(cached_status: "Passed")
        end

        it "does not update the test suite run" do
          expect(test_suite_run).not_to receive(:update!)
          test_suite_run.status
        end
      end
    end
  end
end
