require "rails_helper"

describe TestCaseRun do
  describe "#failed_first" do
    let!(:failed_test_case_run) do
      create(:test_case_run, status: "failed")
    end

    let!(:passed_test_case_run) do
      create(:test_case_run, status: "passed", run: failed_test_case_run.run)
    end

    it "returns the test case runs in order of status" do
      expect(TestCaseRun.failed_first([passed_test_case_run, failed_test_case_run]))
        .to eq([failed_test_case_run, passed_test_case_run])
    end

    describe "alphabetization" do
      let!(:run) { create(:run) }

      let!(:test_case_runs) do
        [
          create(:test_case_run, path: "spec/bbb/zebra_spec.rb", run:),
          create(:test_case_run, path: "spec/zzz/banana_spec.rb", run:)
        ]
      end

      it "sorts by basename" do
        paths = TestCaseRun.failed_first(test_case_runs).map(&:basename)
        expect(paths).to eq(["banana_spec.rb", "zebra_spec.rb"])
      end
    end

    describe "line number" do
      let!(:run) { create(:run) }

      let!(:test_case_runs) do
        [
          create(:test_case_run, path: "spec/models/user_spec.rb", run:, line_number: 2),
          create(:test_case_run, path: "spec/models/user_spec.rb", run:, line_number: 3),
          create(:test_case_run, path: "spec/models/user_spec.rb", run:, line_number: 1)
        ]
      end

      it "sorts by line number" do
        line_numbers = TestCaseRun.failed_first(test_case_runs).map(&:line_number)
        expect(line_numbers).to eq([1, 2, 3])
      end
    end
  end
end
