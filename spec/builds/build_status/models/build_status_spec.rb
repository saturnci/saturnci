require "rails_helper"

RSpec.describe "build status", type: :model do
  describe "#status" do
    let!(:build) { create(:build) }
    let!(:job_1) { create(:job, build: build, order_index: 1) }
    let!(:job_2) { create(:job, build: build, order_index: 2) }

    context "all jobs have passed" do
      it "is passed" do
        allow(job_1).to receive(:status).and_return("Passed")
        allow(job_2).to receive(:status).and_return("Passed")
        allow(build).to receive(:jobs).and_return([job_1, job_2])

        expect(build.status).to eq("Passed")
      end
    end

    context "any jobs have failed" do
      it "is failed" do
        allow(job_1).to receive(:status).and_return("Passed")
        allow(job_2).to receive(:status).and_return("Failed")
        allow(build).to receive(:jobs).and_return([job_1, job_2])

        expect(build.status).to eq("Failed")
      end
    end

    context "some jobs are running, no jobs are failed" do
      it "is running" do
        allow(job_1).to receive(:status).and_return("Passed")
        allow(job_2).to receive(:status).and_return("Running")
        allow(build).to receive(:jobs).and_return([job_1, job_2])

        expect(build.status).to eq("Running")
      end
    end

    context "there are no jobs" do
      it "is running" do
        allow(build).to receive(:jobs).and_return([])

        expect(build.status).to eq("Running")
      end
    end

    describe "caching" do
      context "cache is empty" do
        before do
          allow(job_1).to receive(:status).and_return("Passed")
          allow(job_2).to receive(:status).and_return("Passed")
          allow(build).to receive(:jobs).and_return([job_1, job_2])
        end

        it "sets the cached status" do
          expect { build.status }.to change { build.reload.cached_status }
            .from(nil).to("Passed")
        end
      end

      context "cached_status does not match calculated_status" do
        before do
          build.update!(cached_status: "Passed")
          allow(job_1).to receive(:status).and_return("Failed")
          allow(job_2).to receive(:status).and_return("Failed")
          allow(build).to receive(:jobs).and_return([job_1, job_2])
        end

        it "sets the cached status" do
          expect { build.status }.to change { build.reload.cached_status }
            .from("Passed").to("Failed")
        end
      end

      context "cached_status matches calculated_status" do
        before do
          build.update!(cached_status: "Passed")
          allow(job_1).to receive(:status).and_return("Passed")
          allow(job_2).to receive(:status).and_return("Passed")
          allow(build).to receive(:jobs).and_return([job_1, job_2])
        end

        it "does not update the build" do
          expect(build).not_to receive(:update!)
          build.status
        end
      end
    end
  end
end
