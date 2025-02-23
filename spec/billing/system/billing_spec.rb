require "rails_helper"

describe "Billing", type: :system do
  let!(:run) do
    create(:run, created_at: "2020-01-01")
  end

  before do
    run.finish!
    login_as(run.build.project.user, scope: :user)
    allow_any_instance_of(Charge).to receive(:run_duration).and_return(420)
  end

  context "the current month is January" do
    context "when no date is specified" do
      it "shows runs from January" do
        travel_to "2020-01-01" do
          visit project_billing_path(project_id: run.build.project.id)
          expect(page).to have_content("420")
        end
      end
    end
  end

  context "the current month is February" do
    context "when no date is specified" do
      it "does not show runs from January" do
        travel_to "2020-02-01" do
          visit project_billing_path(project_id: run.build.project.id)
          expect(page).not_to have_content("420")
        end
      end
    end

    context "when a January date is specified" do
      it "shows runs from January" do
        travel_to "2020-02-01" do
          visit project_billing_path(
            project_id: run.build.project.id,
            year: 2020,
            month: 1
          )

          expect(page).to have_content("420")
        end
      end
    end
  end
end
