require "rails_helper"

describe "Default page", type: :system do
  context "signed in" do
    let!(:user) { create(:user) }

    before do
      login_as(user, scope: :user)
    end

    context "no projects exist" do
      it "shows the installations page" do
        visit root_path
        expect(page).to have_content("Installations")
      end
    end

    context "one project exists" do
      before do
        create(:job, build: create(:build, project: create(:project, user:)))
      end

      it "shows the project page" do
        visit "/"
        expect(page).to have_content("Branch:")
      end
    end
  end

  context "not signed in" do
    it "shows the sign-in page" do
      visit root_path
      expect(page).to have_content("Sign in")
    end
  end
end
