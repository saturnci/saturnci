require "rails_helper"

describe TestSuiteRunStatusComponent, type: :component do
  context "test suite run has passed" do
    let!(:task) { create(:task, :passed) }

    before do
      create_list(:test_case_run, 3, task:, status: :passed)
    end

    it "shows the passed count next to the status" do
      component = TestSuiteRunStatusComponent.new(test_suite_run: task.test_suite_run)
      expect(render_inline(component).text).to include("Passed")
      expect(render_inline(component).text).to include("(3)")
    end
  end

  context "test suite run has not passed" do
    let!(:test_suite_run) { create(:test_suite_run, :with_task) }

    it "shows just the status without a count" do
      component = TestSuiteRunStatusComponent.new(test_suite_run:)
      html = render_inline(component).to_html
      expect(html).to include("Running")
      expect(html).not_to include("(")
    end
  end
end
