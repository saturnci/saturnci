require "rails_helper"

describe "Test suite run infinite scroll", type: :system do
  let!(:project) { create(:project) }

  let!(:builds) do
    create_list(:build, 1000, project:)
  end

  before do
    login_as(project.user, scope: :user)
    visit project_build_path(project, builds.first)
  end

  it "initially only shows the first 50 test suite runs" do
  end
end
