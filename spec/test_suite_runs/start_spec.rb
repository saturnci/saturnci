require "rails_helper"

describe "Starting test suite run" do
  let!(:repository) { create(:repository, concurrency: 2) }
  let!(:test_suite_run) { create(:test_suite_run, repository:) }

  before do
    allow(Nova).to receive(:create_k8s_job)
  end

  it "creates workers for each task" do
    expect do
      test_suite_run.start!
    end.to change(Worker, :count).by(2)
  end
end
