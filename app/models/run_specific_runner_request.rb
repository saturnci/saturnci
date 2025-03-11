require "droplet_kit"

class RunSpecificRunnerRequest
  def initialize(run:, github_installation_id:, ssh_key:, client: DropletKitClientFactory.client)
    @run = run
    @github_installation_id = github_installation_id
    @ssh_key = ssh_key
    @client = client
  end

  def execute!
    droplet = DropletKit::Droplet.new(
      name: droplet_name(@run.build.project.name, @run.id),
      region: DropletConfig::REGION,
      image: DropletConfig::SNAPSHOT_IMAGE_ID,
      size: DropletConfig::SIZE,
      user_data: user_data,
      tags: ["saturnci"],
      ssh_keys: [@ssh_key.id]
    )

    droplet_request = @client.droplets.create(droplet)

    ActiveRecord::Base.transaction do
      test_runner = TestRunner.create!(
        name: "test-runner-#{SecureRandom.uuid}",
        cloud_id: droplet_request.id,
      )

      RunTestRunner.create!(test_runner:, run: @run)
    end

    @run.update!(
      snapshot_image_id: DropletConfig::SNAPSHOT_IMAGE_ID,
      runner_id: droplet_request.id
    )
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
    RunnerScript.new(@run, @github_installation_id).content
  end
end
