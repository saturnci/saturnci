class ScreenshotFile
  def initialize(path:)
    @path = path
  end

  def matching_test_case_run(run)
    run.test_case_runs.find_by(line_number:)
  end

  def line_number
    match = File.basename(@path).match(/_(\d+)\.png$/)
    match[1].to_i
  end
end
