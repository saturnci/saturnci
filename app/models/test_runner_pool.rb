class TestRunnerPool
  def self.scale(count, client: DropletKitClientFactory.client)
    ActiveRecord::Base.transaction do
      TestRunner.unassigned.each { |tr| tr.deprovision(client) }
      count.times { TestRunner.provision(client:) }
    end
  end
end
