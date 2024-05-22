require "rails_helper"

describe "Active link", type: :system do
  let!(:project) { create(:project) }
  let!(:build_1) { create(:build, :with_job, project: project) }
  let!(:build_2) { create(:build, :with_job, project: project) }

  before do
    user = create(:user)
    login_as(user, scope: :user)
    visit project_build_path(project, build_1)
  end

  context "link clicked" do
    it "sets that build to active" do
      click_on "build_link_#{build_2.id}"
      expect(page.find("#build_link_#{build_2.id}")[:class].split).to include("active")
    end

    it "sets other builds to inactive" do
      click_on "build_link_#{build_2.id}"
      expect(page.find("#build_link_#{build_2.id}")[:class].split).to include("active")

      click_on "build_link_#{build_1.id}"
      expect(page.find("#build_link_#{build_2.id}")[:class].split).not_to include("active")
    end
  end

  context "page load" do
    it "sets the first build link to active" do
      expect(page.find("#build_link_#{build_1.id}")[:class].split).to include("active")
    end
  end
end
