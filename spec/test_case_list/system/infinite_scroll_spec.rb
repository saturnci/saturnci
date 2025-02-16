require "rails_helper"

describe "Infinite scroll", type: :system do
  let!(:run) { create(:run, :failed) }
  let!(:build) { run.build }

  let!(:last_test_case_run) do
    create(
      :test_case_run,
      path: "spec/models/zebra_spec.rb",
      run:
    )
  end

  before do
    create_list(:test_case_run, 30, run:, path: "spec/models/apple_spec.rb")

    login_as(build.project.user)
    visit project_build_path(id: build.id, project_id: build.project.id)
  end

  it "initially shows only the first 30 test case runs" do
    expect(all(".test-case-run-list-body ul li").count).to eq(30)
  end

  describe "scrolling to the bottom" do
    it "shows any remaining test case runs" do
      scroll_to_bottom
      sleep(0.5) # wait for additional record to load
      scroll_to_bottom

      expect(page).to have_content(last_test_case_run.basename)
    end
  end

  def scroll_to_bottom
    page.execute_script <<~JS
      const list = document.querySelector('.test-case-run-list-body');
      list.scrollTop = list.scrollHeight;
    JS
  end
end
