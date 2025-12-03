require "rails_helper"

describe TestFailureScreenshot do
  describe "#url" do
    let!(:test_failure_screenshot) do
      create(:test_failure_screenshot, path: "screenshots/test_failure.png")
    end

    it "returns a presigned URL" do
      expect(test_failure_screenshot.url).to include("screenshots/test_failure.png")
    end
  end
end
