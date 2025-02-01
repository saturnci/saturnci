class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :github

  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])
    Rails.logger.info "GitHub auth: #{request.env["omniauth.auth"].inspect}"

    if @user.persisted?
      session[:github_oauth_token] = request.env["omniauth.auth"].credentials.token
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "Github") if is_navigational_format?
    else
      # Removing extra as it can overflow some session stores
      session["devise.github_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end
end
