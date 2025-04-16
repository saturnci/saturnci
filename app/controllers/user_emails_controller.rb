class UserEmailsController < ApplicationController
  def new
    @user_email = UserEmail.new(user: current_user)
    authorize @user_email
  end

  def create
    @user_email = UserEmail.new(
      user: current_user,
      email: params[:user_email][:email]
    )

    authorize @user_email

    if @user_email.save
      redirect_to repositories_path
    else
      render :new, status: :unprocessable_entity
    end
  end
end
