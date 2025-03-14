require "rails_helper"

describe TestSuiteRun, type: :model do
  describe "#duration" do
    let!(:build) { create(:build) }

    context "no runs" do
      it "is nil" do
        expect(build.duration).to be nil
      end
    end

    context "one run finished, the other not finished yet" do
      before do
        finished_run = create(:run, build: build, order_index: 1)
        allow(finished_run).to receive(:duration).and_return(5)

        unfinished_run = create(:run, build: build, order_index: 2)
        allow(unfinished_run).to receive(:duration).and_return(nil)

        allow(build).to receive(:runs).and_return([finished_run, unfinished_run])
      end

      it "is nil" do
        expect(build.duration).to be nil
      end
    end

    context "two finished runs" do
      before do
        shorter_run = create(:run, build: build, order_index: 1)
        allow(shorter_run).to receive(:duration).and_return(5)

        longer_run = create(:run, build: build, order_index: 2)
        allow(longer_run).to receive(:duration).and_return(7)

        allow(build).to receive(:runs).and_return([shorter_run, longer_run])
      end

      it "returns the longer of the two runs" do
        expect(build.duration).to eq(7)
      end
    end
  end

  describe "#cancel!" do
    let!(:run) { create(:run, :with_test_runner) }

    before do
      stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{run.test_runner.cloud_id}").to_return(status: 200)
    end

    it "sets the status to 'Cancelled'" do
      run.build.cancel!
      expect(run.build.reload.status).to eq("Cancelled")
    end
  end

  describe "#finished?" do
    context "build status is 'Finished'" do
      let!(:build) { create(:build) }

      before do
        allow(build).to receive(:status).and_return("Finished")
      end

      it "returns true" do
        expect(build.finished?).to be true
      end
    end

    context "build status is 'Running'" do
      let!(:build) { create(:build) }

      before do
        allow(build).to receive(:status).and_return("Running")
      end

      it "returns false" do
        expect(build.finished?).to be false
      end
    end

    context "build status changes from 'Running' to 'Finished'" do
      let!(:build) { create(:build) }

      it "returns true" do
        allow(build).to receive(:status).and_return("Running")
        expect(build.finished?).to be false
        allow(build).to receive(:status).and_return("Finished")
        expect(build.finished?).to be true
      end
    end

    context "build is finished and the finished state is checked twice" do
      let!(:build) { create(:build) }

      it "does not execute a query on the second check" do
        allow(build).to receive(:status).and_return("Finished")

        # Twice because #finished? calls #status twice
        expect(build).to receive(:status).twice

        build.finished?
        build.finished?
      end
    end
  end
end
