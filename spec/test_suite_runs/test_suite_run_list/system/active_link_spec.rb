require "rails_helper"

describe "Active link", type: :system do
  let!(:repository) { create(:repository) }

  let!(:test_suite_run_1) do
    create(:test_suite_run, :with_run, repository: repository)
  end

  let!(:test_suite_run_2) do
    create(:test_suite_run, :with_run, repository: repository)
  end

  let!(:test_suite_run_link_1) do
    PageObjects::TestSuiteRunLink.new(page, test_suite_run_1)
  end

  let!(:test_suite_run_link_2) do
    PageObjects::TestSuiteRunLink.new(page, test_suite_run_2)
  end

  before do
    allow(repository.user).to receive(:can_access_repository?).and_return(true)
    login_as(repository.user)
    visit repository_test_suite_run_path(repository, test_suite_run_1)
  end

  context "link clicked" do
    it "sets that test_suite_run to active" do
      test_suite_run_link_2.click
      expect(test_suite_run_link_2).to be_active
    end

    it "sets other test_suite_runs to inactive" do
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
