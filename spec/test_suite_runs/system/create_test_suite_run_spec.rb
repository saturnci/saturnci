require "rails_helper"

describe "Start test suite run", type: :system do
  let!(:test_suite_run) { create(:build) }

  before do
    create(:user, super_admin: true)

    test_runner = create(:test_runner)
    allow(Worker).to receive(:available).and_return([test_runner])
    allow(Worker).to receive(:create_vm)

    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(test_suite_run.repository.user)
  end

  it "starts the test suite run" do
    perform_enqueued_jobs do
      visit repository_build_path(id: test_suite_run.id, repository_id: test_suite_run.repository.id)
      expect(page).to have_content("Not Started")

      click_on "Start"
      expect(page).to have_content("Running")
    end
  end
end
