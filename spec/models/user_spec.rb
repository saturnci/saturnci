require "rails_helper"

describe User, type: :model do
  it "has an api_token" do
    user = create(:user)
    expect(user.api_token).to be_present
  end
end
