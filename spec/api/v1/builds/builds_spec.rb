require "rails_helper"

RSpec.describe "builds", type: :request do
  describe "POST /api/v1/builds" do
    let!(:project) { create(:project) }

    it "increases the count of builds by 1" do
      expect {
        post api_v1_builds_path
      }.to change(Build, :count).by(1)
    end
  end
end