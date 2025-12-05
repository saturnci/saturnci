require "rails_helper"

describe "Change worker architecture", type: :system do
  let!(:repository) { create(:repository) }

  before do
    allow_any_instance_of(User).to receive(:github_repositories).and_return([repository])
    login_as(repository.user)
    visit repository_settings_general_settings_path(repository)
  end

  it "persists the selection" do
    expect(page).to have_checked_field("Terra")

    choose "Nova"
    click_on "Save"

    expect(page).to have_content("Settings saved")
    expect(page).to have_checked_field("Nova")
  end
end
