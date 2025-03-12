class SillinessController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user_or_404!

  def index
    skip_authorization
    render plain: SillyName.random
  end
end
