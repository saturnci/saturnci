class TestFileDivider
  def initialize(test_files:, task_count:)
    @test_files = test_files
    @task_count = task_count
  end

  def divide
    base_size = @test_files.size / @task_count
    remainder = @test_files.size % @task_count

    result = {}
    start_index = 0

    @task_count.times do |i|
      chunk_size = base_size + (i < remainder ? 1 : 0)
      order_index = i + 1
      result[order_index.to_s] = @test_files[start_index, chunk_size]
      start_index += chunk_size
    end

    result
  end
end
