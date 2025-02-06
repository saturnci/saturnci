class RSpecTestRunSummary
  def initialize(run, raw_data)
    @run = run
    @raw_data = raw_data.with_indifferent_access
  end

  def generate_test_case_runs!
    examples.each do |example|
      @run.test_case_runs.create!(
        identifier: example[:id],
        path: example[:file_path],
        status: example[:status].to_s,
        description: example[:description],
        line_number: example[:line_number],
        duration: example[:run_time]
      )
    end
  end

  private

  def examples
    @raw_data[:examples]
  end
end
