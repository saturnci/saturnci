require "rails_helper"

describe TestCaseRunScreenshot do
  let!(:full_description) do
    "Delete build runner does not still exist on Digital Ocean removes the build"
  end

  let!(:file_path) do
    "tmp/capybara/failures_rspec_example_groups_delete_build_runner_does_not_still_exist_on_digital_ocean_removes_the_build_400.png"
  end

  let!(:test_case_run) do
    create(:test_case_run, description: full_description)
  end

  it "makes the filename" do
    expect(TestCaseRunScreenshot.new(test_case_run).file_path).to eq(file_path)
  end
end
