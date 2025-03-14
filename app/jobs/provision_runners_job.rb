class ProvisionRunnersJob < ApplicationJob
  queue_as :default

  def perform(count)
    count.times { TestRunner.provision }
  end
end
