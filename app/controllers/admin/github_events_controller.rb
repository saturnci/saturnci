module Admin
  class GitHubEventsController < ApplicationController
    def index
      head :unauthorized unless current_user.super_admin?

      @limit = 100
      @all_github_events = GitHubEvent.order("created_at desc")
      @github_events = @all_github_events.limit(@limit)
    end
  end
end
