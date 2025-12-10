require "rails_helper"

describe "Infinite scroll", type: :system do
  include ScrollingHelper

  let!(:task) { create(:task, :failed) }
  let!(:test_suite_run) { task.test_suite_run }

  let!(:last_test_case_run) do
    create(
      :test_case_run,
      path: "spec/models/zebra_spec.rb",
      task:
    )
  end

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)

    create_list(:test_case_run, 100, task:, path: "spec/models/apple_spec.rb")

    login_as(test_suite_run.repository.user)
    visit repository_build_path(id: test_suite_run.id, repository_id: test_suite_run.repository.id)
  end

  it "initially shows only the first 100 test case runs" do
    expect(all(".test-case-run-list-body ul li").count).to eq(100)
  end

  describe "scrolling to the bottom" do
    before do
      scroll_to_bottom(".test-case-run-list-body")
      sleep(0.5) # wait for additional record to load
      scroll_to_bottom(".test-case-run-list-body")
    end

    it "shows any remaining test case runs" do
      expect(page).to have_content(last_test_case_run.basename)
    end

    it "results in 31 test case runs" do
      expect(all(".test-case-run-list-body ul li").count).to eq(101)
    end
  end
end
