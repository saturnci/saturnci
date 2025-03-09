class TestRunnerPool
  def self.scale(count)
    10.times do
      TestRunner.create!(
        name: SecureRandom.hex(8),
        cloud_id: SecureRandom.hex(8)
      )
    end
  end
end
