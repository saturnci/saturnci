class TestSet
  def initialize(test_files)
    @test_files = test_files
  end

  def grouped(number_of_groups)
    @test_files.in_groups(number_of_groups, false)
      .each_with_index
      .to_h { |group, index| [(index + 1).to_s, group] }
  end
end
