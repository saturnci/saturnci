class TestRunnerPool
  def self.scale(count, client: DropletKitClientFactory.client)
    ActiveRecord::Base.transaction do
      change = count - TestRunner.unassigned.count

      if change > 0
        change.times { TestRunner.provision(client:) }
      else
        TestRunner.unassigned.limit(change.abs).each do |tr|
          tr.deprovision(client)
        end
      end
    end
  end
end
