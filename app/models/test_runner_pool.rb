class TestRunnerPool
  def self.scale(count, client: DropletKitClientFactory.client)
    ActiveRecord::Base.transaction do
      TestRunner.destroy_all

      count.times do
        TestRunner.provision(client:)
      end
    end
  end
end
