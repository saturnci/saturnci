module API
  module V1
    class TestSuiteRunsController < APIController
      DEFAULT_LIMIT = 30

      def index
        authorize :test_suite_run, :index?

        test_suite_runs = TestSuiteRun
          .where(repository_id: current_user.github_repositories.map(&:id))
          .order("created_at DESC")
          .limit(DEFAULT_LIMIT)
          .as_json(methods: %w[status duration_formatted])

        render json: test_suite_runs
      end

      def show
        test_suite_run = TestSuiteRun.find_by_abbreviated_hash(params[:id])
        authorize test_suite_run

        render json: {
          id: test_suite_run.id,
          status: test_suite_run.status,
          branch_name: test_suite_run.branch_name,
          commit_hash: test_suite_run.commit_hash,
          commit_message: test_suite_run.commit_message,
          failed_tests: test_suite_run.test_case_runs.failed.map do |test_case_run|
            {
              path: test_case_run.path,
              line_number: test_case_run.line_number,
              description: test_case_run.description,
              exception: test_case_run.exception,
              exception_message: test_case_run.exception_message,
              exception_backtrace: test_case_run.exception_backtrace
            }
          end,
          _links: {
            self: { href: api_v1_test_suite_run_url(test_suite_run) },
            tasks: test_suite_run.tasks.map { |task| { href: api_v1_task_url(task) } }
          }
        }
      end

      def update
        test_suite_run = TestSuiteRun.find(params[:id])
        authorize test_suite_run, :update?

        test_suite_run.update!(test_suite_run_params)
        render json: test_suite_run
      end

      def create
        repository = Repository.find_by!(github_repo_full_name: params[:repository])

        test_suite_run = TestSuiteRun.new(
          repository: repository,
          branch_name: params[:branch_name],
          commit_hash: params[:commit_hash],
          commit_message: params[:commit_message],
          author_name: params[:author_name]
        )
        authorize test_suite_run

        test_suite_run.start!

        render json: {
          id: test_suite_run.id,
          runs: test_suite_run.runs.map { |run| { id: run.id } }
        }
      end

      private

      def test_suite_run_params
        params.permit(:dry_run_example_count)
      end
    end
  end
end
