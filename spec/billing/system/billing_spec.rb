require "rails_helper"

describe "Billing", type: :system do
  let!(:job) do
    create(:job, created_at: "2020-01-01")
  end

  before do
    login_as(job.build.project.user, scope: :user)
    allow_any_instance_of(Job).to receive(:duration).and_return(420)
  end

  context "the current month is January" do
    context "when no date is specified" do
      it "shows jobs from January" do
        travel_to "2020-01-01" do
          visit project_billing_path(project_id: job.build.project.id)
          expect(page).to have_content("420")
        end
      end
    end
  end

  context "the current month is February" do
    context "when no date is specified" do
      it "does not show jobs from January" do
        travel_to "2020-02-01" do
          visit project_billing_path(project_id: job.build.project.id)
          expect(page).not_to have_content("420")
        end
      end
    end

    context "when a January date is specified" do
      it "shows jobs from January" do
        travel_to "2020-02-01" do
          visit project_billing_path(
            project_id: job.build.project.id,
            year: 2020,
            month: 1
          )

          expect(page).to have_content("420")
        end
      end
    end
  end
end
