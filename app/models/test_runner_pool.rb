class TestRunnerPool
  def self.scale(count, client: DropletKitClientFactory.client, test_runner_droplet_specification: nil)
    ActiveRecord::Base.transaction do
      change = count - TestRunner.unassigned.count
      puts "Change: #{change}"

      if change > 0
        change.times do
          TestRunner.provision(
            client:,
            test_runner_droplet_specification:
          )
        end
      else
        TestRunner.unassigned.limit(change.abs).each do |tr|
          tr.deprovision(client)
        end
      end
    end
  end
end
