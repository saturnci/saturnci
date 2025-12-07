require "rails_helper"

describe "DELETE test_suite_run", type: :request do
  let!(:test_suite_run) { create(:test_suite_run) }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(test_suite_run.repository.user)
    Nova.start_test_suite_run(test_suite_run)
  end

  it "enqueues a DeleteTaskWorkerJob for each task" do
    expect {
      delete repository_test_suite_run_path(
        repository_id: test_suite_run.repository_id,
        id: test_suite_run.id
      )
    }.to have_enqueued_job(Nova::DeleteTaskWorkerJob).exactly(test_suite_run.tasks.count).times
  end
end
