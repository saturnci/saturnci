require 'rails_helper'

describe 'Bootstrap', type: :system, js: true do
  it "uses bootstrap" do
    visit "/bootstrap.html"
    expect(page).to have_content "blah"
  end
end
