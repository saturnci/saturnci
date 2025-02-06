require "rails_helper"

describe RSpecTestRunSummary do
  let!(:run) { create(:run) }

  context "multiple examples" do
    let!(:raw_data) do
      {
        version: "3.13.2",
        seed: 1864,
        examples: [
          {
            id: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb[1:1:1:1]",
            description: "does not show the system log content",
            full_description: "Visiting different tab visiting a different tab after log update occurs does not show the system log content",
            status: "passed",
            file_path: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb",
            line_number: 28,
            run_time: 12.255599035,
            pending_message: nil
          },
          {
            id: "./spec/api/v1/runner_spec.rb[1:1:1]",
            description: "deletes the runner",
            full_description: "delete runner terminate_on_completion is true deletes the runner",
            status: "passed",
            file_path: "./spec/api/v1/runner_spec.rb",
            line_number: 16,
            run_time: 0.413684976,
            pending_message: nil
          },
          {
            id: "./spec/api/v1/runner_spec.rb[1:2:1]",
            description: "does not delete the runner",
            full_description: "delete runner terminate_on_completion is false does not delete the runner",
            status: "passed",
            file_path: "./spec/api/v1/runner_spec.rb",
            line_number: 36,
            run_time: 0.136240481,
            pending_message: nil
          }
        ],
        summary: {
          duration: 152.692154288,
          example_count: 3,
          failure_count: 0,
          pending_count: 0,
          errors_outside_of_examples_count: 0
        },
        summary_line: "3 examples, 0 failures"
      }
    end

    let!(:rspec_test_run_summary) do
      RSpecTestRunSummary.new(run, raw_data)
    end

    it "works" do
      expect {
        rspec_test_run_summary.generate_test_case_runs!
      }.to change {
        run.reload.test_case_runs.count
      }.by(3)
    end
  end

  describe "exception" do
    context "when there is an exception" do
      let!(:raw_data) do
        {
          examples: [
            {
              id: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb[1:1:1:1]",
              description: "does not show the system log content",
              full_description: "Visiting different tab visiting a different tab after log update occurs does not show the system log content",
              status: "failed",
              file_path: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb",
              line_number: 28,
              run_time: 12.255599035,
              exception: {
                "class" => "RSpec::Expectations::ExpectationNotMetError",
                "message" => "\nexpected: 10000\n     got: 0.3e0\n\n(compared using ==)\n",
                "backtrace" => [
                  "./spec/models/charge_spec.rb:16:in `block (3 levels) in <main>'",
                  "/usr/local/bundle/gems/webmock-3.24.0/lib/webmock/rspec.rb:39:in `block (2 levels) in <top (required)>'"
                ]
              },
              pending_message: nil
            },
          ]
        }
      end

      let!(:rspec_test_run_summary) do
        RSpecTestRunSummary.new(run, raw_data)
      end

      it "sets the exception message" do
        rspec_test_run_summary.generate_test_case_runs!
        expect(run.reload.test_case_runs.first.exception_message).to eq("expected: 10000\n     got: 0.3e0\n\n(compared using ==)")
      end

      it "sets the exception backtrace" do
        rspec_test_run_summary.generate_test_case_runs!
        expect(run.reload.test_case_runs.first.exception_backtrace).to eq("./spec/models/charge_spec.rb:16:in `block (3 levels) in <main>'\n/usr/local/bundle/gems/webmock-3.24.0/lib/webmock/rspec.rb:39:in `block (2 levels) in <top (required)>'")
      end
    end

    context "when there is no exception" do
      let!(:raw_data) do
        {
          examples: [
            {
              id: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb[1:1:1:1]",
              description: "does not show the system log content",
              full_description: "Visiting different tab visiting a different tab after log update occurs does not show the system log content",
              status: "passed",
              file_path: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb",
              line_number: 28,
              run_time: 12.255599035,
              pending_message: nil
            },
          ]
        }
      end

      let!(:rspec_test_run_summary) do
        RSpecTestRunSummary.new(run, raw_data)
      end

      it "sets exception to nil" do
        rspec_test_run_summary.generate_test_case_runs!
        expect(run.reload.test_case_runs.first.exception).to be_nil
      end

      it "gives a blank message" do
        rspec_test_run_summary.generate_test_case_runs!
        expect(run.reload.test_case_runs.first.exception_message).to be_blank
      end

      it "gives a blank backtrace" do
        rspec_test_run_summary.generate_test_case_runs!
        expect(run.reload.test_case_runs.first.exception_backtrace).to be_blank
      end
    end
  end

  describe "status" do
    context "passed" do
      let!(:raw_data) do
        {
          examples: [
            {
              id: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb[1:1:1:1]",
              description: "does not show the system log content",
              full_description: "Visiting different tab visiting a different tab after log update occurs does not show the system log content",
              status: "passed",
              file_path: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb",
              line_number: 28,
              run_time: 12.255599035,
              pending_message: nil
            },
          ]
        }
      end

      let!(:rspec_test_run_summary) do
        RSpecTestRunSummary.new(run, raw_data)
      end

      it "sets status to passed" do
        rspec_test_run_summary.generate_test_case_runs!
        expect(run.reload.test_case_runs.first.status).to eq("passed")
      end
    end

    context "failed" do
      let!(:raw_data) do
        {
          examples: [
            {
              id: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb[1:1:1:1]",
              description: "does not show the system log content",
              full_description: "Visiting different tab visiting a different tab after log update occurs does not show the system log content",
              status: "failed",
              file_path: "./spec/streaming/system_logs/system/visiting_different_tab_spec.rb",
              line_number: 28,
              run_time: 12.255599035,
              pending_message: nil
            },
          ]
        }
      end

      let!(:rspec_test_run_summary) do
        RSpecTestRunSummary.new(run, raw_data)
      end

      it "sets status to failed" do
        rspec_test_run_summary.generate_test_case_runs!
        expect(run.reload.test_case_runs.first.status).to eq("failed")
      end
    end
  end
end
