module Admin
  class GitHubEventsController < ApplicationController
    def index
      head :unauthorized unless current_user.super_admin?

      @github_events = GitHubEvent.order("created_at desc")
    end
  end
end
