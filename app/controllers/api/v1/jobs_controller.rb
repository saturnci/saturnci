module API
  module V1
    class JobsController < APIController
      def index
        render json: Job.joins(:build)
          .running
          .order("builds.created_at desc")
      end
    end
  end
end

# ./saturnci jobs
# ID        Created              Build status  Build ID  Build commit message
# 3895127d  2024-02-29 16:44:14  Running       cdbe84c7  Fix order.
# 74bd6903  2024-02-29 16:40:10  Running       6882b373  Add ID column.
# 172eb0a3  2024-02-29 16:44:15  Running       cdbe84c7  Fix order.
# 70c9f470  2024-02-29 16:40:10  Running       6882b373  Add ID column.
