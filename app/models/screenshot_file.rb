class ScreenshotFile
  def initialize(path:)
    @path = path
  end

  def matching_test_case_run(run)
    run.test_case_runs.find do |test_case_run|
      snake_case_test_case_description = test_case_run.description.downcase.gsub(" ", "_")
      File.basename(@path).include?(snake_case_test_case_description)
    end
  end
end
