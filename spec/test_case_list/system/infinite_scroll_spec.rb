require "rails_helper"

describe "Infinite scroll", type: :system do
  let!(:run) { create(:run, :failed) }
  let!(:build) { run.build }

  let!(:test_case_runs) do
    create_list(
      :test_case_run,
      30,
      path: "spec/models/apple_spec.rb",
      run:
    )
  end

  let!(:last_test_case_run) do
    create(
      :test_case_run,
      path: "spec/models/zebra_spec.rb",
      run:
    )
  end

  before do
    login_as(build.project.user)
    visit project_build_path(id: build.id, project_id: build.project.id)
  end

  it "initially shows only the first 30 test case runs" do
    expect(all(".build-overview-test-case-runs li").count).to eq(30)
  end

  describe "scrolling to the bottom" do
    it "shows any remaining test case runs" do
      page.execute_script <<~JS
        var list = document.querySelector('.test-case-run-list-body');
        list.scrollTop = list.scrollHeight;
      JS

      expect(page).to have_content(last_test_case_run.path)
    end
  end
end
