require "rails_helper"

RSpec.describe "build status", type: :model do
  describe "#status" do
    context "no runs" do
      it "is 'Not Started'" do
        build = create(:build)
        expect(build.status).to eq("Not Started")
      end
    end

    context "some runs" do
      let!(:build) { create(:build) }
      let!(:run_1) { create(:run, build: build, order_index: 1) }
      let!(:run_2) { create(:run, build: build, order_index: 2) }

      context "all runs have passed" do
        it "is passed" do
          allow(run_1).to receive(:status).and_return("Passed")
          allow(run_2).to receive(:status).and_return("Passed")
          allow(build).to receive(:runs).and_return([run_1, run_2])

          expect(build.status).to eq("Passed")
        end
      end

      context "any runs have failed" do
        it "is failed" do
          allow(run_1).to receive(:status).and_return("Passed")
          allow(run_2).to receive(:status).and_return("Failed")
          allow(build).to receive(:runs).and_return([run_1, run_2])

          expect(build.status).to eq("Failed")
        end
      end

      context "some runs are running, no runs are failed" do
        it "is running" do
          allow(run_1).to receive(:status).and_return("Passed")
          allow(run_2).to receive(:status).and_return("Running")
          allow(build).to receive(:runs).and_return([run_1, run_2])

          expect(build.status).to eq("Running")
        end
      end

      context "there are no runs" do
        it "is not started" do
          allow(build).to receive(:runs).and_return([])

          expect(build.status).to eq("Not Started")
        end
      end

      describe "caching" do
        context "cache is empty" do
          before do
            allow(run_1).to receive(:status).and_return("Passed")
            allow(run_2).to receive(:status).and_return("Passed")
            allow(build).to receive(:runs).and_return([run_1, run_2])
          end

          it "sets the cached status" do
            expect { build.status }.to change { build.reload.cached_status }
              .from(nil).to("Passed")
          end
        end

        context "cached_status does not match calculated_status" do
          before do
            build.update!(cached_status: "Passed")
            allow(run_1).to receive(:status).and_return("Failed")
            allow(run_2).to receive(:status).and_return("Failed")
            allow(build).to receive(:runs).and_return([run_1, run_2])
          end

          it "sets the cached status" do
            expect { build.status }.to change { build.reload.cached_status }
              .from("Passed").to("Failed")
          end
        end

        context "cached_status matches calculated_status" do
          before do
            build.update!(cached_status: "Passed")
            allow(run_1).to receive(:status).and_return("Passed")
            allow(run_2).to receive(:status).and_return("Passed")
            allow(build).to receive(:runs).and_return([run_1, run_2])
          end

          it "does not update the build" do
            expect(build).not_to receive(:update!)
            build.status
          end
        end
      end
    end
  end
end
