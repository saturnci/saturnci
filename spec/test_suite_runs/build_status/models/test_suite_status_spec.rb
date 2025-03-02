require "rails_helper"

describe "test suite run status", type: :model do
  describe "#status" do
    context "no runs" do
      it "is 'Not Started'" do
        test_suite_run = create(:build)
        expect(test_suite_run.status).to eq("Not Started")
      end
    end

    context "some runs" do
      let!(:test_suite_run) { create(:build) }
      let!(:run_1) { create(:run, build: test_suite_run, order_index: 1) }
      let!(:run_2) { create(:run, build: test_suite_run, order_index: 2) }

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
        context "cache is empty" do
          before do
            allow(run_1).to receive(:status).and_return("Passed")
            allow(run_2).to receive(:status).and_return("Passed")
            allow(test_suite_run).to receive(:runs).and_return([run_1, run_2])
          end

          it "sets the cached status" do
            expect { test_suite_run.status }.to change { test_suite_run.reload.cached_status }
              .from(nil).to("Passed")
          end
        end

        context "cached_status does not match calculated_status" do
          before do
            test_suite_run.update!(cached_status: "Passed")
            allow(run_1).to receive(:status).and_return("Failed")
            allow(run_2).to receive(:status).and_return("Failed")
            allow(test_suite_run).to receive(:runs).and_return([run_1, run_2])
          end

          it "sets the cached status" do
            expect { test_suite_run.status }.to change { test_suite_run.reload.cached_status }
              .from("Passed").to("Failed")
          end
        end

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
end
