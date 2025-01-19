module GitHubEvents
  class Installation
    def initialize(payload)
      @payload = payload
    end

    def process
      user.saturn_installations.create!(
        github_installation_id: @payload["installation"]["id"],
        account_name: @payload["installation"]["account"]["login"],
      )
    end

    private

    def user
      User.find_by!(uid: github_account_id, provider: "github")
    end

    def github_account_id
      if @payload["installation"]["account"]["type"] == "Organization"
        @payload["sender"]["id"]
      else
        @payload["installation"]["account"]["id"]
      end
    end
  end
end
