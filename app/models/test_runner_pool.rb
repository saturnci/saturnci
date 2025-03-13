class TestRunnerPool
  def self.scale(count, client: DropletKitClientFactory.client)
    ActiveRecord::Base.transaction do
      change = count - TestRunner.unassigned.count
      puts "Change: #{change}"

      if change > 0
        add(change, client:)
      else
        TestRunner.unassigned.limit(change.abs).each do |tr|
          tr.deprovision(client)
        end
      end
    end
  end

  def self.add(count, client: DropletKitClientFactory.client)
    count.times { TestRunner.provision(client:) }
  end
end
