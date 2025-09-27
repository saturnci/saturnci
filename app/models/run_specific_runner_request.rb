require "droplet_kit"

class RunSpecificRunnerRequest
  def initialize(run:, github_installation_id:, ssh_key:, client: DropletKitClientFactory.client)
    @run = run
    @github_installation_id = github_installation_id
    @ssh_key = ssh_key
    @client = client
  end

  def execute!
    test_runner = TestRunner.provision(
      client: @client,
      ssh_key: @ssh_key,
      name: droplet_name(@run.project.name, @run.id),
      user_data:
    )

    RunTestRunner.create!(test_runner:, run: @run)
  end

  def droplet_name(project_name, run_id)
    [
      project_name.gsub("/", "-").gsub("_", "-"),
      "run",
      run_id[0..7]
    ].join("-")
  end

  private

  # /var/lib/cloud/instances/456688083/scripts/part-001
  def user_data
    TestRunnerAgentScript.new(@run, @github_installation_id).content
  end
end
