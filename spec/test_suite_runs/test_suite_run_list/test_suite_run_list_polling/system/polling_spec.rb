require "rails_helper"

describe "Polling", type: :system do
  let!(:repository) { create(:repository) }
  let!(:test_suite_run) { create(:test_suite_run, :with_passed_run, repository: repository) }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(repository.user)
    visit task_path(test_suite_run.runs.first, "system_logs")
  end

  context "when content changes" do
    it "updates the list" do
      expect(page).not_to have_content("abc12345")

      create(:test_suite_run, repository: repository, commit_hash: "abc12345")

      expect(page).to have_content("abc12345", wait: 3)
    end
  end

  context "when content is unchanged" do
    it "does not replace DOM elements" do
      list_item = find("#test_suite_run_#{test_suite_run.id}")
      page.execute_script("arguments[0].dataset.testMarker = 'original'", list_item)

      sleep 2.5

      list_item = find("#test_suite_run_#{test_suite_run.id}")
      expect(list_item["data-test-marker"]).to eq("original")
    end
  end
end
