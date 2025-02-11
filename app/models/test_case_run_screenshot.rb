class TestCaseRunScreenshot
  SIZE = 400
  BASE_PATH = "tmp/capybara"

  def initialize(test_case_run)
    @test_case_run = test_case_run
  end

  def file_path
    "#{BASE_PATH}/failures_rspec_example_groups_#{test_case}_#{SIZE}.png"
  end

  private

  def test_case
    @test_case_run.description.parameterize(separator: "_")
  end
end
