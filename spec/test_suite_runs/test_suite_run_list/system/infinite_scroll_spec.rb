require "rails_helper"

describe "Test suite run infinite scroll", type: :system do
  include ScrollingHelper

  let!(:project) { create(:project) }

  describe "large number of test suite runs" do
    let!(:builds) do
      create_list(:build, 100, project:)
    end

    before do
      login_as(project.user, scope: :user)
      visit project_build_path(project, builds.first)
    end

    it "initially only shows the first 20 test suite runs" do
      expect(page).to have_css(".test-suite-run-link", count: 20)
    end

    describe "scrolling to the bottom" do
      before do
        scroll_to_bottom(".test-suite-run-list")
        sleep(0.5) # wait for additional record to load
        scroll_to_bottom(".test-suite-run-list")
      end

      it "shows 20 more test suite runs" do
        expect(page).to have_css(".test-suite-run-link", count: 40)
      end
    end
  end
end
