require "rails_helper"

describe Run, type: :model do
  describe "#running" do
    let!(:running_run) do
      create(:run, exit_code: nil)
    end

    let!(:finished_run) do
      create(:run, exit_code: 0)
    end

    it "by default includes the running run" do
      expect(Run.running).to include(running_run)
    end

    it "by default does not include the finished run" do
      expect(Run.running).not_to include(finished_run)
    end
  end

  context "two builds" do
    let!(:build_1) { create(:build) }
    let!(:build_2) { create(:build, created_at: build_1.created_at + 1.minute) }

    before do
      create(:run, build: build_1, order_index: 1)
      create(:run, build: build_1, order_index: 2)

      create(:run, build: build_2, order_index: 1)
      create(:run, build: build_2, order_index: 2)
    end

    it "groups by build" do
      expected_ids = [
        build_2.id,
        build_2.id,
        build_1.id,
        build_1.id,
      ]

      expect(Run.running.map(&:build_id)).to eq(expected_ids)
    end
  end
end
