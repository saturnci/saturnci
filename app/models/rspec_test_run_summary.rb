class RSpecTestRunSummary
  def initialize(run, raw_data)
    @run = run
    @raw_data = raw_data.with_indifferent_access
  end

  def generate_test_case_runs!
    ActiveRecord::Base.transaction do
      examples.each do |example|
        @run.test_case_runs.create!(
          identifier: example[:id],
          path: example[:file_path],
          status: example[:status].to_s,
          description: example[:full_description],
          line_number: example[:line_number],
          exception: example[:exception],
          exception_message: example[:exception] && example[:exception][:message].strip,
          exception_backtrace: example[:exception] && example[:exception][:backtrace].join("\n"),
          duration: example[:run_time]
        )
      end
    end
  end

  private

  def examples
    @raw_data[:examples]
  end
end
