namespace :db do
  namespace :migrate do
    task concurrent: :environment do
      ActiveRecord::MigrationContext.new("db/migrate").migrate
    rescue ActiveRecord::ConcurrentMigrationError
      print "Skipping migrations because other migrations are already running"
    end
  end
end
