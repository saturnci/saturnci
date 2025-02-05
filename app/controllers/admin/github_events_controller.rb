module Admin
  class GitHubEventsController < ApplicationController
    def index
      @limit = 100
      @all_github_events = GitHubEvent.order("created_at desc")
      @github_events = @all_github_events.limit(@limit)

      authorize @github_events
    end
  end
end
