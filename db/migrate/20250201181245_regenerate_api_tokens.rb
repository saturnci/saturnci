class RegenerateAPITokens < ActiveRecord::Migration[8.0]
  def change
    User.all.each do |user|
      user.regenerate_api_token
    end
  end
end
