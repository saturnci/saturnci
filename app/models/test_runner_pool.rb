class TestRunnerPool
  def self.scale(count)
    ActiveRecord::Base.transaction do
      TestRunner.destroy_all

      count.times do
        TestRunner.create!(
          name: SecureRandom.hex(8),
          cloud_id: SecureRandom.hex(8)
        )
      end
    end
  end
end
