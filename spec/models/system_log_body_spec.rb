require "rails_helper"

RSpec.describe SystemLogBody do
  it "stripts the noise" do
    content = "Oct 29 11:56:28 saturnci-saturnci-job-45ac18d9-f22d-4625-b602-babe3a681358 cloud-init[1233]: dd34835689af: Preparing"
    system_log_body = SystemLogBody.new(content)
    expect(system_log_body.scrub).to eq("Oct 29 11:56:28 cloud-init[1233]: dd34835689af: Preparing")
  end
end
