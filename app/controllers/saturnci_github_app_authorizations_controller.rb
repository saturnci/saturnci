class SaturnCIGitHubAppAuthorizationsController < ApplicationController
  skip_before_action :authenticate_user_or_404!

  def new
    skip_authorization
  end
end
