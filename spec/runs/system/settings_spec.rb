require "rails_helper"

describe "Settings", type: :system do
  let!(:run) { create(:run) }

  describe "turning off 'terminate on completion'" do
    before do
      login_as(run.build.project.user)
    end

    it "leaves the checkbox unchecked" do
      visit run_path(run, "settings")
      uncheck "Terminate runner once run is complete"
      click_on "Save"
      expect(page).to have_content("Settings updated")
      expect(page).to have_unchecked_field("Terminate runner once run is complete")
    end
  end
end
