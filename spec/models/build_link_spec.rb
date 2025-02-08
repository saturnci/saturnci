require "rails_helper"

describe BuildLink do
  include Rails.application.routes.url_helpers

  context "build is finished" do
    let!(:build) { create(:build, :with_failed_run) }

    it "links to overview page" do
      expect(BuildLink.new(build).path).to eq(project_build_path(build.project, build))
    end
  end

  context "there are no runs" do
    let!(:build) { create(:build) }

    it "returns the project build path" do
      expect(BuildLink.new(build).path).to eq(project_build_path(build.project, build))
    end
  end

  context "there are runs" do
    let!(:run_1) { create(:run, order_index: 1) }
    let!(:run_2) { create(:run, order_index: 2, build: run_1.build) }
    let!(:build) { run_1.build }

    context "no failed runs" do
      it "links to the first run" do
        expect(BuildLink.new(build).path).to include(run_1.id.to_s)
      end
    end

    context "one failed run" do
      before do
        run_2.update!(exit_code: 1)
      end

      it "links to the failed run" do
        expect(BuildLink.new(build).path).to include(run_2.id.to_s)
      end
    end

    context "successful run followed by failed run" do
      before do
        expect(BuildLink.new(build).path).to include(run_1.id.to_s)
      end

      it "works" do
        travel_to(1.minute.from_now) do
          run_2.update!(exit_code: 1)
          expect(BuildLink.new(build).path).to include(run_2.id.to_s)
        end
      end
    end
  end
end
