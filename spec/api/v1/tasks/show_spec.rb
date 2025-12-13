require "rails_helper"

describe "GET /api/v1/tasks/:id", type: :request do
  let!(:user) { create(:user, super_admin: true) }
  let!(:personal_access_token) { create(:personal_access_token, user:) }
  let!(:test_suite_run) { create(:build) }
  let!(:task) { create(:task, test_suite_run:) }
  let!(:worker) { create(:worker, task:) }
  let!(:event1) { create(:worker_event, worker:, name: "task_fetched", created_at: Time.zone.parse("2025-01-01 12:00:00")) }
  let!(:event2) { create(:worker_event, worker:, name: "docker_ready", notes: "14.5", created_at: Time.zone.parse("2025-01-01 12:00:10")) }

  let(:credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials(
      user.id.to_s,
      personal_access_token.access_token.value
    )
  end

  it "returns the task events with durations" do
    get(api_v1_task_path(task), headers: { "Authorization" => credentials })

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)

    expect(body["events"].length).to eq(2)
    expect(body["events"][0]["name"]).to eq("task_fetched")
    expect(body["events"][0]["interval_since_previous_event"]).to be_nil
    expect(body["events"][1]["name"]).to eq("docker_ready")
    expect(body["events"][1]["notes"]).to eq("14.5")
    expect(body["events"][1]["interval_since_previous_event"]).to eq(10.0)
  end
end
