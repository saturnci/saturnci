module GitHubEvents
  class Installation
    def initialize(payload)
      @payload = payload
    end

    def process
      Rails.logger.info "Processing GitHub Installation event"

      user.github_accounts.create!(
        github_installation_id: @payload["installation"]["id"],
        github_app_installation_url: @payload["installation"]["html_url"],
        account_name: @payload["installation"]["account"]["login"],
        installation_response_payload: @payload,
      )
    end

    private

    def user
      Rails.logger.info "GitHub user id: #{github_user_id}"

      User.find_by!(uid: github_user_id, provider: "github")
    end

    def github_user_id
      Rails.logger.info "Account type: #{@payload["installation"]["account"]["type"]}"

      if @payload["installation"]["account"]["type"] == "Organization"
        @payload["sender"]["id"]
      else
        @payload["installation"]["account"]["id"]
      end
    end
  end
end
