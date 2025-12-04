class ProvisionRunnersJob < ApplicationJob
  queue_as :default

  def perform(count)
    count.times { Worker.provision }
  end
end
