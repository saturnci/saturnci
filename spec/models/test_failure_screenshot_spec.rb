require "rails_helper"

describe TestFailureScreenshot do
  describe "#url" do
    let!(:test_failure_screenshot) do
      create(:test_failure_screenshot, path: "screenshots/test_failure.png")
    end

    before do
      presigner = instance_double(Aws::S3::Presigner)
      allow(Aws::S3::Presigner).to receive(:new).and_return(presigner)
      allow(presigner).to receive(:presigned_url).and_return(
        "https://example.com/screenshots/test_failure.png?signed=true"
      )
    end

    it "returns a presigned URL" do
      expect(test_failure_screenshot.url).to include("screenshots/test_failure.png")
    end
  end
end
