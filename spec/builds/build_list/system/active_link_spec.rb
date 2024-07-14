require "rails_helper"

describe "Active link", type: :system do
  let!(:project) { create(:project) }

  let!(:build_1) do
    create(:build, :with_job, project: project)
  end

  let!(:build_2) do
    create(:build, :with_job, project: project)
  end

  let!(:build_link_1) do
    PageObjects::BuildLink.new(page, build_1)
  end

  let!(:build_link_2) do
    PageObjects::BuildLink.new(page, build_2)
  end

  before do
    user = create(:user)
    login_as(user, scope: :user)
    visit project_build_path(project, build_1)
  end

  context "link clicked" do
    it "sets that build to active" do
      build_link_2.click
      expect(build_link_2).to be_active
    end

    it "sets other builds to inactive" do
      build_link_2.click
      expect(build_link_2).to be_active

      build_link_1.click
      expect(build_link_2).not_to be_active
    end
  end

  context "page load" do
    it "sets the first build link to active" do
      expect(build_link_1).to be_active
    end
  end
end
