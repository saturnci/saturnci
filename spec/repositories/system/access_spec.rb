require "rails_helper"

describe "Repository access", type: :system do
  let!(:user) { create(:user) }

  before do
    login_as(user)
  end

  xit "works" do
    # before:
    # there's a repo called panda
    # user has GitHub access to panda
    # panda exists as a repository in SaturnCI
    create(:repository, name: "panda")

    visit repositories_path
    expect(page).to have_content("panda")
  end
end
