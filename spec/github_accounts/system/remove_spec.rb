require "rails_helper"

describe "Remove installation", type: :system do
  let!(:github_account) { create(:github_account) }

  before do
    login_as(github_account.user, scope: :user)
  end

  it "deletes the installation" do
    visit github_accounts_path
    click_on "Remove"

    expect(page).not_to have_content(github_account.github_installation_id)
  end
end
