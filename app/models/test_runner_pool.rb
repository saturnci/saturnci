class TestRunnerPool
  def self.scale(count)
    ActiveRecord::Base.transaction do
      change = count - TestRunner.unassigned.count
      puts "Change: #{change}"

      if change > 0
        change.times { TestRunner.provision }
      else
        TestRunner.unassigned.limit(change.abs).each do |tr|
          tr.destroy
        end
      end
    end
  end
end
