require "rails_helper"

describe "Active link", type: :system do
  let!(:project) { create(:project) }

  let!(:build_1) do
    create(:build, :with_run, project: project)
  end

  let!(:build_2) do
    create(:build, :with_run, project: project)
  end

  let!(:test_suite_run_link_1) do
    PageObjects::TestSuiteRunLink.new(page, build_1)
  end

  let!(:test_suite_run_link_2) do
    PageObjects::TestSuiteRunLink.new(page, build_2)
  end

  before do
    allow(project.user).to receive(:can_access_repository?).and_return(true)
    login_as(project.user)
    visit project_build_path(project, build_1)
  end

  context "link clicked" do
    it "sets that build to active" do
      test_suite_run_link_2.click
      expect(test_suite_run_link_2).to be_active
    end

    it "sets other builds to inactive" do
      test_suite_run_link_2.click
      expect(test_suite_run_link_2).to be_active

      test_suite_run_link_1.click
      expect(test_suite_run_link_2).not_to be_active
    end
  end

  context "page load" do
    it "sets the first test suite run link to active" do
      expect(test_suite_run_link_1).to be_active
    end
  end
end
