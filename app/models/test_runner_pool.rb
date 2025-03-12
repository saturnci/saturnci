class TestRunnerPool
  def self.scale(count, client: DropletKitClientFactory.client)
    ActiveRecord::Base.transaction do
      TestRunner.unassigned.each(&:deprovision)

      count.times do
        TestRunner.provision(client:, user_data: script)
      end
    end
  end

  def self.script
    <<~SCRIPT
      #!/bin/bash
      cd ~
      git clone https://github.com/saturnci/test_runner_agent.git
    SCRIPT
  end
end
