class ScreenshotFile
  MATCH_PREFIX_LENGTH = 50

  def initialize(path:)
    @path = path
  end

  def matching_test_case_run(run)
    run.test_case_runs.find do |test_case_run|
      snake_case_description = test_case_run.description.downcase.gsub(/[^\w]+/, "_")
      match_prefix = snake_case_description[0, MATCH_PREFIX_LENGTH]
      File.basename(@path).include?(match_prefix)
    end
  end
end
