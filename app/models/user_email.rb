class UserEmail
  include ActiveModel::Model
  attr_accessor :user, :email
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def save
    return unless valid?
    user.update!(email:)
  end
end
