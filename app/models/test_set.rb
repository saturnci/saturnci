class TestSet
  def initialize(test_files)
    @test_files = test_files
  end

  def grouped(number_of_groups)
    base_size = @test_files.size / number_of_groups
    remainder = @test_files.size % number_of_groups

    result = {}
    start_index = 0

    number_of_groups.times do |i|
      chunk_size = base_size + (i < remainder ? 1 : 0)
      group_index = i + 1
      result[group_index.to_s] = @test_files[start_index, chunk_size]
      start_index += chunk_size
    end

    result
  end
end
